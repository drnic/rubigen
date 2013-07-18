class InstallRubigenScriptsGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(RbConfig::CONFIG['bindir'],
                              RbConfig::CONFIG['ruby_install_name'])
  
  default_options :shebang => DEFAULT_SHEBANG
  
  attr_reader :path, :scopes
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.length < 2 # requires path and at least one scope
    @path             = args.shift
    @destination_root = File.expand_path(path)
    @scopes           = args.map { |scope| scope.to_sym }
    default_scopes
    extract_options
  end

  def manifest
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory "script"

      %w( generate destroy ).each do |file|
        m.template "script/#{file}",        "script/#{file}", script_options
        m.template "script/win_script.cmd", "script/#{file}.cmd", 
          :assigns => { :filename => file } if windows
      end
    end
  end
  
  def scopes_str
    scopes.inspect
  end
  
  protected
    def banner
      <<-EOS
Installs script/generate and script/destroy scripts into current folder

USAGE: #{spec.name} install_path scope[ scope]

For example: #{spec.name} . rails rubygems
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      opts.on("-r", "--ruby=path", String,
             "Path to the Ruby binary of your choice (otherwise scripts use env, dispatchers current path).",
             "Default: #{DEFAULT_SHEBANG}") { |v| options[:shebang] = v }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
    
    def default_scopes
      if (scopes.map { |s| s.to_s } & %w[test_unit rspec test_spec mini_spec javascript_test]).blank?
        scopes << :test_unit
      end
    end

end