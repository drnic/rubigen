class ComponentGeneratorGenerator < RubiGen::Base

  default_options

  attr_reader :name, :class_name
  attr_reader :generator_type, :generator_path

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name           = args.shift
    @class_name     = "#{name}_generator".camelize
    @generator_type = args.shift # optional
    @generator_path = @generator_type ? "#{generator_type}_generators" : "generators"
    extract_options
  end

  def manifest
    path = "#{generator_path}/#{name}"
    record do |m|
      # Ensure appropriate generators folder exists
      m.directory "#{path}/templates"
      m.directory "test"

      # Generator stub
      m.template generator,              "#{path}/#{name}_generator.rb"
      m.template "test.rb",                   "test/test_#{name}_generator.rb"
      m.file     "test_generator_helper.rb",  "test/test_generator_helper.rb"
      m.file     "usage",                     "#{path}/USAGE"
      m.readme   'readme'
    end
  end

  def generator
    case (generator_type.to_sym rescue nil)
    when :rails
      "rails_generator.rb"
    else
      "generator.rb"
    end
  end

  def superclass_name
    case (generator_type.to_sym rescue nil)
    when :rails
      "Rails::Generator::NamedBase"
    else
      "RubiGen::Base"
    end
  end

  def superclass_requirement
    case (generator_type.to_sym rescue nil)
    when :rails
      ["rails_generator"]
    else
      []
    end
  end

  protected
    def banner
      <<-EOS
Creates a generator stub within your RubyGem.

USAGE: #{$0} #{spec.name} name [generator_type]
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Generated app file will include your name.",
      #         "Default: none") { |o| options[:author] = 0 }
    end

    def extract_options
    end
end