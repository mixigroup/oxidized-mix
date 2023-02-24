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
  end
end

::Oxidized::Model.prepend OxidizedMix::Oxidized::CommentTrimmable
