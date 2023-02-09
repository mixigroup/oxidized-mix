require 'asetus'

require_relative 'asetus/adapter/yaml'

module OxidizedMix
  # Override the behavior of Asetus
  # - Do nothing with create()
  module CreateIgnorable
    def create(opts = {}) end
  end

  # Override the behavior of Asetus
  # - Load ConfigStruct and override
  module ConfigLoadable
    def load_from_config(config)
      @cfg = merge @cfg, config
    end
  end
end

Asetus.prepend OxidizedMix::CreateIgnorable
Asetus.include OxidizedMix::ConfigLoadable
