class TestUnitGenerator < RubiGen::Base
  
  attr_reader :name, :test_name, :class_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name           = args.shift
    @test_name      = "test_#{name}".underscore
    @class_name     = name.camelize
  end
  
  def manifest
    record do |m|
      m.directory 'test'

      # Model class, unit test, and fixtures.
      m.template 'test.rb',  "test/#{test_name}.rb"
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} NameOfTest"
    end
end
