require 'oxidized/core'

module OxidizedMix
  module Oxidized
    # Override the behavior of Oxidized::Core
    # - Run once instead of daemonizing
    module OnceRunnable
      def run
        ::Oxidized.logger.debug 'lib/oxidized/core.rb: Starting the worker...'

        @worker.until_finished do
          @worker.work
        end
      end
    end

    # Override the behavior of Oxidized::Core
    # - Access results after worker is done
    module CoreResultAccessible
      def failed_nodes
        @worker.failed_nodes
      end

      def succeeded_nodes
        @worker.succeeded_nodes
      end
    end
  end
end

::Oxidized::Core.prepend OxidizedMix::Oxidized::OnceRunnable
::Oxidized::Core.include OxidizedMix::Oxidized::CoreResultAccessible
