require 'asetus'

require_relative 'asetus/adapter/yaml'

module OxidizedMix
  # Override the behavior of Asetus
  # - Do nothing with create()
  module CreateIgnorable
    def create(opts = {}) end
  end
end

Asetus.prepend OxidizedMix::CreateIgnorable
