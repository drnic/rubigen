require 'rbconfig'

class RubyAppGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

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
    dispatcher_options = { :chmod => 0755, :shebang => options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    record do |m|
      # Root directory and all subdirectories.
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      # Root
      m.file "fresh_rakefile", "Rakefile"
      m.file "README.txt",     "README.txt"

     # Scripts
      %w( generate ).each do |file|
        m.file     "script/#{file}",        "script/#{file}", script_options
        m.template "script/win_script.cmd", "script/#{file}.cmd", 
          :assigns => { :filename => file } if windows
      end
      
      # Default module for app
      m.template "module.rb",         "lib/#{app_name}.rb", script_options
      
      # Test helper
      m.template "test_helper.rb",    "test/test_helper.rb", script_options

      %w(debug).each { |file|
        m.file "configs/empty.log", "log/#{file}.log", :chmod => 0666
      }
    end
  end

  protected
    def banner
      "Usage: #{$0} /path/to/your/app [options]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("-r", "--ruby=path", String,
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
