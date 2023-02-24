require 'oxidized/model/model'

module OxidizedMix
  module Oxidized
    # Override the behavior of Oxidized::Model
    # - Remove trailing spaces
    module CommentTrimmable
      def comment(_str)
        super.gsub(/ +\n/, "\n")
      end
    end

    # Override the behavior of Oxidized::Model
    # - Print commands to execute
    module CommandPrintable
      def process_cmd_output(output, name)
        super.prepend("#{self.class.comment}[ #{name} ]\n")
      end
    end
  end
end

::Oxidized::Model.prepend OxidizedMix::Oxidized::CommentTrimmable
::Oxidized::Model.prepend OxidizedMix::Oxidized::CommandPrintable
