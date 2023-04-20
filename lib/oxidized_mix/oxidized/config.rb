require 'etc'
require 'oxidized/config'

module OxidizedMix
  module Oxidized
    # Override the behavior of Oxidized::Config
    # - Pre-define MIXI specific configs
    module ConfigDefinable
      # class methods
      module ClassMethods
        # rubocop:disable Metrics/AbcSize
        def load_custom(extra_config)
          ::Oxidized.asetus.load_from_config extra_config

          ::Oxidized.config.username    = Etc.getpwuid(Process.uid).name
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

          # onyx (model: "mlnxos") is very slow
          ::Oxidized.config.timeout = 30

          # same as Oxidized::Jobs::AVERAGE_DURATION to increase @want of Jobs to node count
          ::Oxidized.config.interval = 5

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
