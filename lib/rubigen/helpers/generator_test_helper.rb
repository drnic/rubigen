require 'stringio'

module RubiGen
  module GeneratorTestHelper
    # Runs the create command (like the command line does)
    def run_generator(name, params, sources, options = {})
      generator = build_generator(name, params, sources, options)
      silence_generator do
        generator.command(:create).invoke!
      end
      generator
    end

    # Instatiates the Generator
    def build_generator(name, params, sources, options)
      @stdout ||= StringIO.new
      options.merge!(:collision => :force)  # so no questions are prompted
      options.merge!(:stdout => @stdout)  # so stdout is piped to a StringIO
      if sources.is_a?(Symbol)
        if sources == :app
          RubiGen::Base.use_application_sources!
        else
          RubiGen::Base.use_component_sources!
        end
      else
        RubiGen::Base.reset_sources
        RubiGen::Base.prepend_sources(*sources) unless sources.blank?
      end
      RubiGen::Base.instance(name, params, options)
    end

    # Silences the logger temporarily and returns the output as a String
    def silence_generator
      logger_original      = RubiGen::Base.logger
      myout                = StringIO.new
      RubiGen::Base.logger = RubiGen::SimpleLogger.new(myout)
      yield if block_given?
      RubiGen::Base.logger = logger_original
      myout.string
    end

    # asserts that the given file was generated.
    # the contents of the file is passed to a block.
    def assert_generated_file(path)
      assert_file_exists(path)
      File.open("#{APP_ROOT}/#{path}") do |f|
        yield f.read if block_given?
      end
    end

    # asserts that the given file exists
    def assert_file_exists(path)
      assert File.exists?("#{APP_ROOT}/#{path}"),"The file '#{path}' should exist"
    end

    # asserts that the given directory exists
    def assert_directory_exists(path)
      assert File.directory?("#{APP_ROOT}/#{path}"),"The directory '#{path}' should exist"
    end

    # asserts that the given class source file was generated.
    # It takes a path without the <tt>.rb</tt> part and an optional super class.
    # the contents of the class source file is passed to a block.
    def assert_generated_class(path,parent=nil)
      path=~/\/?(\d+_)?(\w+)$/
      class_name=$2.camelize
      assert_generated_file("#{path}.rb") do |body|
        assert body=~/class #{class_name}#{parent.nil? ? '':" < #{parent}"}/,"the file '#{path}.rb' should be a class"
        yield body if block_given?
      end
    end

    # asserts that the given module source file was generated.
    # It takes a path without the <tt>.rb</tt> part.
    # the contents of the class source file is passed to a block.
    def assert_generated_module(path)
      path=~/\/?(\w+)$/
      module_name=$1.camelize
      assert_generated_file("#{path}.rb") do |body|
        assert body=~/module #{module_name}/,"the file '#{path}.rb' should be a module"
        yield body if block_given?
      end
    end

    # asserts that the given unit test was generated.
    # It takes a name or symbol without the <tt>test_</tt> part and an optional super class.
    # the contents of the class source file is passed to a block.
    def assert_generated_test_for(name, parent="Test::Unit::TestCase")
      assert_generated_class "test/test_#{name.to_s.underscore}", parent do |body|
        yield body if block_given?
      end
    end

    # asserts that the given methods are defined in the body.
    # This does assume standard rails code conventions with regards to the source code.
    # The body of each individual method is passed to a block.
    def assert_has_method(body,*methods)
      methods.each do |name|
        assert body=~/^  def #{name.to_s}\n((\n|   .*\n)*)  end/,"should have method #{name.to_s}"
        yield( name, $1 ) if block_given?
      end
    end
    
    def app_root_files
      Dir[APP_ROOT + '/**/*']
    end

    def rubygem_folders
      %w[bin examples lib test]
    end
  
    def rubygems_setup
      bare_setup
      rubygem_folders.each do |folder|
        Dir.mkdir("#{APP_ROOT}/#{folder}") unless File.exists?("#{APP_ROOT}/#{folder}")
      end
    end
  
    def rubygems_teardown
      bare_teardown
    end
  
    def bare_setup
      FileUtils.mkdir_p(APP_ROOT)
      @stdout = StringIO.new
    end
  
    def bare_teardown
      FileUtils.rm_rf TMP_ROOT || APP_ROOT
    end
  
  end
end
