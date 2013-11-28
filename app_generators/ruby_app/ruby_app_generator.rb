require 'rbconfig'

class RubyAppGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(RbConfig::CONFIG['bindir'],
                              RbConfig::CONFIG['ruby_install_name'])

  default_options   :shebang => DEFAULT_SHEBANG
  
  attr_accessor :app_name
  attr_accessor :module_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    self.app_name     = File.basename(File.expand_path(@destination_root))
    self.module_name  = app_name.camelize
  end

  def manifest
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    record do |m|
      # Root directory and all subdirectories.
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      # Root
      # m.file "fresh_rakefile", "Rakefile"
      # m.file "README.txt",     "README.txt"
      m.folder ""

      # Default module for app
      m.template "lib/module.rb",         "lib/#{app_name}.rb"
      
      # Test helper
      m.template_copy_each %w(test_helper.rb.erb),    "test"

      %w(debug).each { |file|
        m.file "configs/empty_log", "log/#{file}.log", :chmod => 0666
      }
      
      m.dependency "install_rubigen_scripts", [destination_root, "rubygems"], :shebang => options[:shebang]
    end
  end

  protected
    def banner
      "Usage: #{$0} /path/to/your/app [options]"
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      opts.on("-r", "--ruby=path", String,
             "Path to the Ruby binary of your choice (otherwise scripts use env, dispatchers current path).",
             "Default: #{DEFAULT_SHEBANG}") { |v| options[:shebang] = v }
    end
    

  # Installation skeleton.  Intermediate directories are automatically
  # created so don't sweat their absence here.
  BASEDIRS = %w(
    doc
    lib
    log
    script
    test
    tmp
  )
end
