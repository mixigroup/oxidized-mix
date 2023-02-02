require 'oxidized/config'

module OxidizedMix
  module Oxidized
    # Override the behavior of Oxidized::Config
    # - Pre-define MIXI specific configs
    module ConfigDefinable
      # class methods
      module ClassMethods
        # rubocop:disable Metrics/AbcSize
        def load_custom(cmd_opts = {})
          load cmd_opts

          ::Oxidized.config.username    = nil
          ::Oxidized.config.resolve_dns = false
          ::Oxidized.config.rest        = false
          # ::Oxidized.config.debug       = true

          ::Oxidized.config.input.default         = 'ssh'
          ::Oxidized.config.output.file.directory = '.'
          ::Oxidized.config.source.csv.file       = 'router.db'
          ::Oxidized.config.source.csv.delimiter  = /:/
          ::Oxidized.config.source.csv.map.name   = 0
          ::Oxidized.config.source.csv.map.model  = 1
          ::Oxidized.config.source.csv.map.group  = 2

          # custom config
          ::Oxidized.config.repos = %w[~/my-repo]

          # onyx (model: "mlnxos") is very slow
          ::Oxidized.config.timeout = 30

          ::Oxidized.config
        end

        # rubocop:enable Metrics/AbcSize
      end

      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end

::Oxidized::Config.include OxidizedMix::Oxidized::ConfigDefinable