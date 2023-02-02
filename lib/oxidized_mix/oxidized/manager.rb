require 'oxidized/manager'

module OxidizedMix
  module Oxidized
    # Override the behavior of Oxidized::Manager
    # - Load custom models from this gem
    module CustomModelLoadable
      # Act as singleton to use pre-loaded custom models
      module ClassMethods
        def new
          @new ||= super
        end
      end

      def self.included(base)
        base.singleton_class.prepend ClassMethods
      end

      def load_custom_models
        dir = File.expand_path('model', __dir__)
        Dir["#{dir}/*.rb"].each do |path|
          ::Oxidized.logger.info %(loading a custom model "#{path}")
          @model.merge! ::Oxidized::Manager.load(dir, File.basename(path, '.rb'))
        end
      end
    end
  end
end

::Oxidized::Manager.include OxidizedMix::Oxidized::CustomModelLoadable
