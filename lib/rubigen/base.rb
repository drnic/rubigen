require File.dirname(__FILE__) + '/options'
require File.dirname(__FILE__) + '/manifest'
require File.dirname(__FILE__) + '/spec'
require File.dirname(__FILE__) + '/generated_attribute'

# RubiGen is a code generation platform Ruby frameworks.  
# Generators are easily invoked within Ruby framework instances
# to add and remove components such as library and test files.
#
# New generators are easy to create and may be distributed within RubyGems,
# user home directory, or within each Ruby framework that uses RubiGen.
#
# For example, newgem uses RubiGen to generate new RubyGems. Those 
# generated RubyGems can then use RubiGen (via a generated script/generate 
# application) to generate tests and executable apps, etc, for the RubyGem.
#
# Generators may subclass other generators to provide variations that
# require little or no new logic but replace the template files.
#
# For a RubyGem, put your generator classes and templates within subfolders
# of the +generators+ directory. 
#
# The layout of generator files can be seen in the built-in 
# +test_unit+ generator:
#   
#   test_unit_generators/
#     test_unit/
#       test_unit_generator.rb
#       templates/
#         test_unit.rb
#
# The directory name (+test_unit+) matches the name of the generator file
# (test_unit_generator.rb) and class (+TestUnitGenerator+). The files
# that will be copied or used as templates are stored in the +templates+
# directory.
#
# The filenames of the templates don't matter, but choose something that
# will be self-explanatory since you will be referencing these in the 
# +manifest+ method inside your generator subclass.
#
# 
module RubiGen
  class GeneratorError < StandardError; end
  class UsageError < GeneratorError; end


  # The base code generator is bare-bones.  It sets up the source and
  # destination paths and tells the logger whether to keep its trap shut.
  #
  # It's useful for copying files such as stylesheets, images, or 
  # javascripts.
  #
  # For more comprehensive template-based passive code generation with
  # arguments, you'll want RubiGen::NamedBase. 
  #
  # Generators create a manifest of the actions they perform then hand
  # the manifest to a command which replays the actions to do the heavy
  # lifting (such as checking for existing files or creating directories
  # if needed). Create, destroy, and list commands are included.  Since a
  # single manifest may be used by any command, creating new generators is
  # as simple as writing some code templates and declaring what you'd like
  # to do with them.
  #
  # The manifest method must be implemented by subclasses, returning a
  # RubiGen::Manifest.  The +record+ method is provided as a
  # convenience for manifest creation.  Example:
  #
  #   class StylesheetGenerator < RubiGen::Base
  #     def manifest
  #       record do |m|
  #         m.directory('public/stylesheets')
  #         m.file('application.css', 'public/stylesheets/application.css')
  #       end
  #     end
  #   end
  #
  # See RubiGen::Commands::Create for a list of methods available
  # to the manifest.
  class Base
    include Options

    # Declare default options for the generator.  These options
    # are inherited to subclasses.
    default_options :collision => :ask, :quiet => false, :stdout => STDOUT

    # A logger instance available everywhere in the generator.
    cattr_accessor :logger

    # Either RubiGen::Base, or a subclass (e.g. Rails::Generator::Base)
    # Currently used to determine the lookup paths via the overriden const_missing mechansim
    # in lookup.rb
    cattr_accessor :active

    # Every generator that is dynamically looked up is tagged with a
    # Spec describing where it was found.
    class_inheritable_accessor :spec

    attr_reader :source_root, :destination_root, :args, :stdout

    def initialize(runtime_args, runtime_options = {})
      @args = runtime_args
      parse!(@args, runtime_options)

      # Derive source and destination paths.
      @source_root = options[:source] || File.join(spec.path, 'templates')
      if options[:destination]
        @destination_root = options[:destination]
      elsif defined? ::APP_ROOT
        @destination_root = ::APP_ROOT
      elsif defined? ::RAILS_ROOT
        @destination_root = ::RAILS_ROOT
      end

      # Silence the logger if requested.
      logger.quiet = options[:quiet]
      
      @stdout = options[:stdout]

      # Raise usage error if help is requested.
      usage if options[:help]
    end

    # Generators must provide a manifest.  Use the +record+ method to create
    # a new manifest and record your generator's actions.
    def manifest
      raise NotImplementedError, "No manifest for '#{spec.name}' generator."
    end

    # Return the full path from the source root for the given path.
    # Example for source_root = '/source':
    #   source_path('some/path.rb') == '/source/some/path.rb'
    #
    # The given path may include a colon ':' character to indicate that
    # the file belongs to another generator.  This notation allows any
    # generator to borrow files from another.  Example:
    #   source_path('model:fixture.yml') = '/model/source/path/fixture.yml'
    def source_path(relative_source)
      # Check whether we're referring to another generator's file.
      name, path = relative_source.split(':', 2)

      # If not, return the full path to our source file.
      if path.nil?
        File.join(source_root, name)

      # Otherwise, ask our referral for the file.
      else
        # FIXME: this is broken, though almost always true.  Others'
        # source_root are not necessarily the templates dir.
        File.join(self.class.lookup(name).path, 'templates', path)
      end
    end

    # Return the full path from the destination root for the given path.
    # Example for destination_root = '/dest':
    #   destination_path('some/path.rb') == '/dest/some/path.rb'
    def destination_path(relative_destination)
      File.expand_path(File.join(destination_root, relative_destination))
    end
    
    # Return the basename of the destination_root, 
    # BUT, if it is trunk, tags, or branches, it continues to the
    # parent path for the name
    def base_name
      name = File.basename(destination_root)
      root = destination_root
      while %w[trunk branches tags].include? name
        root = File.expand_path(File.join(root, ".."))
        name = File.basename(root)
      end
      name
    end
    
    def after_generate
    end

    protected
      # Convenience method for generator subclasses to record a manifest.
      def record
        RubiGen::Manifest.new(self) { |m| yield m }
      end

      # Override with your own usage banner.
      def banner
        "Usage: #{$0} #{spec.name} [options]"
      end

      # Read USAGE from file in generator base path.
      def usage_message
        File.read(File.join(spec.path, 'USAGE')) rescue ''
      end
  end

end
