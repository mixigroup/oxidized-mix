require 'asetus/configstruct'
require 'oxidized/cli'

module OxidizedMix
  module Oxidized
    # Util modules
    module CLIUtil
      attr_reader :extra_config

      private

      def empty_argv
        argv = ARGV.dup
        ARGV.clear
        result = yield

        ARGV.replace argv
        result
      end

      def custom_options(opts)
        # disable "--daemonize"
        opts.options.reject! { |o| o.flag == '--daemonize' }

        add_custom_options opts
        opts
      end

      def pick_extra_config(result)
        config = ::Asetus::ConfigStruct.new

        config.output.git.user = result[:git_user]
        config.output.git.email = result[:git_email]
        config.repos = result[:repo]

        config
      end
    end

    # Wrapper of Oxidized::CLI to customize
    class CLI < ::Oxidized::CLI
      include CLIUtil

      def parse_opts
        # parse once to tweak the default parser
        _, opts = empty_argv { super }

        result = Slop::Parser.new(
          custom_options(opts.options),
          **Slop::Options::DEFAULT_CONFIG
        ).parse(ARGV)
        @extra_config = pick_extra_config(result)

        [result.arguments, result]
      end

      def add_custom_options(opts)
        opts.string '--git-user', 'git user name to add commits', required: true
        opts.string '--git-email', 'git user email to add commits', required: true
        opts.array '--repo', 'repository working directory where oxidized works', required: true
      end
    end
  end
end
