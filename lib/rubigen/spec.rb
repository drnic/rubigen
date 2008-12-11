module RubiGen
  # A spec knows where a generator was found and how to instantiate it.
  # Metadata include the generator's name, its base path, and the source
  # which yielded it (PathSource, GemPathSource, etc.)
  class Spec
    attr_reader :name, :path, :source

    def initialize(name, path, source)
      @name, @path, @source, @klass = name, path, source, nil
    end

    # Look up the generator class.  Require its class file, find the class
    # in ObjectSpace, tag it with this spec, and return.
    def klass
      unless @klass
        require class_file
        @klass = lookup_class
        @klass.spec = self
      end
      @klass
    end

    def class_file
      "#{path}/#{name}_generator.rb"
    end

    def class_name
      "#{name.camelize}Generator"
    end

    def usage_file
      "#{path}/USAGE"
    end

    def visible?
      File.exists? usage_file
    end

    private
      # Search for the first Class descending from RubiGen::Base
      # whose name matches the requested class name.
      def lookup_class
        ObjectSpace.each_object(Class) do |obj|
          return obj if valid_superclass?(obj) and
                        obj.name.split('::').last == class_name
        end
        raise NameError, "Missing #{class_name} class in #{class_file}"
      end

      def valid_superclass?(obj)
        valid_generator_superclasses.each do |klass|
          return true if obj.ancestors.include?(klass)
        end
        false
      end

      def valid_generator_superclasses
        @valid_generator_superclasses ||= [
          "RubiGen::Base",
          "Rails::Generator::Base"
        ].inject([]) do |list, class_name|
          klass = class_name.split("::").inject(Object) do |klass, name|
            klass.const_get(name) rescue nil
          end
          list << klass if klass
          list
        end
      end
  end
end
