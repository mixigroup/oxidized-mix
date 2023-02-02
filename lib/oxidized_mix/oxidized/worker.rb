require 'oxidized/worker'

module OxidizedMix
  module Oxidized
    # Override the behavior of Oxidized::Worker
    # - Join worker threads
    module Joinable
      def until_finished
        until @completed
          yield
          sleep ::Oxidized::Config::Sleep
        end
      end

      def run_done_hook
        @completed = true
        super
      end
    end

    # Override the behavior of Oxidized::Worker
    # - Access results after worker is done
    module WorkerResultAccessible
      def failed_nodes
        @nodes.reject { |node| node.stats.successes.positive? }
      end

      def succeeded_nodes
        @nodes.select { |node| node.stats.successes.positive? }
      end
    end
  end
end

::Oxidized::Worker.prepend OxidizedMix::Oxidized::Joinable
::Oxidized::Worker.include OxidizedMix::Oxidized::WorkerResultAccessible
