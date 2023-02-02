require 'asetus/adapter/yaml'
require 'yaml'

module OxidizedMix
  module Asetus
    module Adapter
      # Override the behavior of Asetus::Adapter::YAML:
      # - Ruby 3.1 introduced a breaking change to psych where YAML.load cannot parse "!ruby/regexp" in yaml.
      #   Use .unsafe_load instead of .load.
      module UnsafeLoadable
        # class methods
        module ClassMethods
          def from(yaml)
            if ::YAML.respond_to?(:unsafe_load)
              ::YAML.unsafe_load yaml
            else
              ::YAML.load yaml
            end
          end
        end

        def self.included(base)
          base.singleton_class.prepend ClassMethods
        end
      end
    end
  end
end

::Asetus::Adapter::YAML.include OxidizedMix::Asetus::Adapter::UnsafeLoadable
