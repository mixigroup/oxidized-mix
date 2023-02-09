require 'asetus/configstruct'
require 'oxidized/script/cli'

module OxidizedMix
  module Oxidized
    module Script
      # Wrapper of Oxidized::CLI to customize
      class CLI < ::Oxidized::Script::CLI
        include Oxidized::CLIUtil

        def opts_parse(cmd)
          # parse once to tweak the default parser
          _, opts = empty_argv { super }

          result = Slop::Parser.new(
            custom_options(opts.options),
            **Slop::Options::DEFAULT_CONFIG
          ).parse(ARGV)
          @extra_config = pick_extra_config(result)
          remove_arguments

          super
        end

        private

        def add_custom_options(opts)
          opts.array '--repo', 'repository working directory where oxidized works', required: true
        end

        def remove_arguments
          return unless (i = ARGV.index('--repo'))

          ARGV.delete_at i + 1 unless ARGV[i + 1]&.start_with?('-')
          ARGV.delete_at i
        end
      end
    end
  end
end
