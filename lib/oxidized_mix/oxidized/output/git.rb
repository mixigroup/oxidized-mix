#--
# Copyright (c) 2023 MIXI, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# ---
#
# This is derived from material copyright
#   2013-2015 Saku Ytti <saku@ytti.fi>
#   2013-2015 Samer Abdel-Hafez <sam@arahant.net>
#
#   Licensed under the Apache License, Version 2.0 (the "License"); you may not use
#   this file except in compliance with the License. You may obtain a copy of the
#   License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
#++

# rubocop:disable all
require 'oxidized/output/git'

module OxidizedMix
  module Oxidized
    module Output
      # Override the behavior of Oxidized::Git
      # - Store files in sub-directories which are named as group names
      module SubdirStorable
        # Modified copy of https://github.com/ytti/oxidized/blob/0.28.0/lib/oxidized/output/git.rb#L143-L169
        def update(repo, file, data)
          return if data.empty?

          repo = @cfg.repos[file] || repo

          if @opt[:group]
            if @cfg.single_repo?
              file = if @cfg.subdir.empty?
                       File.join @opt[:group], file
                     else
                       File.join @cfg.subdir, @opt[:group], file
                     end
            else
              repo = if repo.is_a?(::String)
                       if @cfg.subdir.empty?
                         File.join File.dirname(repo), @opt[:group] + '.git'
                       else
                         File.join File.dirname(repo), @cfg.subdir, @opt[:group] + '.git'
                       end
                     else
                       repo[@opt[:group]]
                     end
            end
          end

          begin
            repo = Rugged::Repository.new repo
            update_repo repo, file, data
          rescue Rugged::OSError, Rugged::RepositoryError => open_error
            begin
              Rugged::Repository.init_at repo, :bare
            rescue StandardError => create_error
              raise GitError, "first '#{open_error.message}' was raised while opening git repo, then '#{create_error.message}' was while trying to create git repo"
            end
            retry
          end
        end
      end
    end
  end
end

module OxidizedMix
  module Oxidized
    module Output
      # Override the behavior of Oxidized::Git
      # - Don't run "git commit" per node. Do it per group
      module PerGroupCommittable
        # modified copy of https://github.com/ytti/oxidized/blob/0.28.0/lib/oxidized/output/git.rb#L171-L189

        # "repository path" => {
        #   "group name 1" => [<struct file=..., data=...>, ...],
        #   "group name 2" => [<struct file=..., data=...>, ...],
        #   ...
        # }
        @@_updated_files = Hash.new { |h1, k1|
          h1[k1] = Hash.new { |h2, k2| h2[k2] = [] }
        }

        # write in file system, instead of git object tree
        def update_repo(repo, file, data)
          oid_old = repo.blob_at(repo.head.target_id, file) rescue nil
          return false if oid_old && (oid_old.content.b == data.b)

          obj = Struct.new(:repo, :file, :data, :user, :email)
          @@_updated_files[repo.path][@opt[:group]] << obj.new(repo, file, data, @user, @email)

          @@_hook_registered ||= register_hook # register once
          true
        end

        def self.prepended(base)
          class << base
            def commit_per_group
              @@_updated_files.each do |_, files_per_repo|
                files_per_repo.each do |group, data|
                  next if data.empty?

                  # reuse the repo instance and data in the first entry
                  repo = data[0].repo
                  repo.config['user.name'] = data[0].user
                  repo.config['user.email'] = data[0].email
                  index = repo.index

                  data.each do |d|
                    oid = repo.write d.data, :blob
                    index.add path: d.file, oid: oid, mode: 0o100644
                  end

                  Rugged::Commit.create(repo,
                                        tree: index.write_tree(repo),
                                        message: "Update#{group.empty? ? '' : " #{group}"} by oxidized",
                                        parents: repo.empty? ? [] : [repo.head.target].compact,
                                        update_ref: 'HEAD')
                  index.write
                end
              end
            end
          end
        end

        private

        # Register an unofficial hook to git commit
        def register_hook
          hook = Struct.new(:name, :hook)
          ::Oxidized.hooks.registered_hooks[:nodes_done] << hook.new('gitcommit', GitCommit.new)

          true
        end
      end

      class GitCommit < ::Oxidized::Hook
        def run_hook(ctx)
          ::Oxidized::Git.commit_per_group
        end
      end
    end
  end
end

::Oxidized::Git.prepend OxidizedMix::Oxidized::Output::SubdirStorable
::Oxidized::Git.prepend OxidizedMix::Oxidized::Output::PerGroupCommittable
