require 'oxidized/source/csv'

module OxidizedMix
  module Oxidized
    module Source
      # Override the behavior of Oxidized::CSV
      # - Support multi repo while the original oxidized assumes single-repo
      module MultiRepoize
        # rubocop:disable Metrics/AbcSize
        def load(_node_want = nil)
          return super if ::Oxidized.config.repos.empty?

          original_file = ::Oxidized.config.source.csv.file
          nodes         = []
          node_to_repo  = {}
          ::Oxidized.config.repos.each do |repo|
            repo_path = File.expand_path(repo) # extract something like ~
            next unless File.directory?(repo_path)

            ::Oxidized.config.source.csv.file = File.join(repo_path, original_file)

            # Remember repo. There is no good place to store this within original class structures.
            nodes += super.each { |n| node_to_repo[n[:name]] = repo_path }
          end

          ::Oxidized.config.output.git.repos = node_to_repo
          ::Oxidized.config.source.csv.file  = original_file
          nodes

          # rubocop:enable Metrics/AbcSize
        end
      end
    end
  end
end

::Oxidized::CSV.prepend OxidizedMix::Oxidized::Source::MultiRepoize
