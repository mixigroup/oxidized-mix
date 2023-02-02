# rubocop:disable all
require 'oxidized/output/git'

module OxidizedMix
  module Oxidized
    module Output
      # Override the behavior of Oxidized::Git
      # - Store files in sub-directories which are named as group names
      module SubdirStorable
        # Copy from oxidized-0.28.0/lib/oxidized/output/git.rb in gem, and customize
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

::Oxidized::Git.prepend OxidizedMix::Oxidized::Output::SubdirStorable
