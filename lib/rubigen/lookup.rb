require File.dirname(__FILE__) + '/spec'

class Object
  class << self
    # Lookup missing generators using const_missing.  This allows any
    # generator to reference another without having to know its location:
    # RubyGems, ~/.rubigen/generators, and APP_ROOT/generators.
    def lookup_missing_generator(class_id)
      if md = /(.+)Generator$/.match(class_id.to_s)
        name = md.captures.first.demodulize.underscore
        RubiGen::Base.active.lookup(name).klass
      else
        const_missing_before_generators(class_id)
      end
    end

    unless respond_to?(:const_missing_before_generators)
      alias_method :const_missing_before_generators, :const_missing
      alias_method :const_missing, :lookup_missing_generator
    end
  end
end

# User home directory lookup adapted from RubyGems.
def Dir.user_home
  if ENV['HOME']
    ENV['HOME']
  elsif ENV['USERPROFILE']
    ENV['USERPROFILE']
  elsif ENV['HOMEDRIVE'] and ENV['HOMEPATH']
    "#{ENV['HOMEDRIVE']}:#{ENV['HOMEPATH']}"
  else
    File.expand_path '~'
  end
end


module RubiGen

  # Generator lookup is managed by a list of sources which return specs
  # describing where to find and how to create generators.  This module
  # provides class methods for manipulating the source list and looking up
  # generator specs, and an #instance wrapper for quickly instantiating
  # generators by name.
  #
  # A spec is not a generator:  it's a description of where to find
  # the generator and how to create it.  A source is anything that
  # yields generators from #each.  PathSource and GemGeneratorSource are provided.
  module Lookup
    def self.included(base)
      base.extend(ClassMethods)
      # base.use_component_sources!  # TODO is this required since it has no scope/source context
    end

    # Convenience method to instantiate another generator.
    def instance(generator_name, args, runtime_options = {})
      self.class.active.instance(generator_name, args, runtime_options)
    end

    module ClassMethods
      # The list of sources where we look, in order, for generators.
      def sources
        if read_inheritable_attribute(:sources).blank?
          if superclass == RubiGen::Base
            superclass_sources = superclass.sources
            diff = superclass_sources.inject([]) do |mem, source|
              found = false
              application_sources.each { |app_source| found ||= true if app_source == source}
              mem << source unless found
              mem
            end
            write_inheritable_attribute(:sources, diff)
          end
          active.use_component_sources! if read_inheritable_attribute(:sources).blank?
        end
        read_inheritable_attribute(:sources)
      end

      # Add a source to the end of the list.
      def append_sources(*args)
        sources.concat(args.flatten)
        invalidate_cache!
      end

      # Add a source to the beginning of the list.
      def prepend_sources(*args)
        sources = self.sources
        reset_sources
        write_inheritable_array(:sources, args.flatten + sources)
        invalidate_cache!
      end

      # Reset the source list.
      def reset_sources
        write_inheritable_attribute(:sources, [])
        invalidate_cache!
      end
      
      # Use application generators (app, ?).
      def use_application_sources!(*filters)
        reset_sources
        write_inheritable_attribute(:sources, application_sources(filters))
      end
      
      def application_sources(filters = [])
        filters.unshift 'app'
        app_sources = []
        app_sources << PathSource.new(:builtin, File.join(File.dirname(__FILE__), %w[.. .. app_generators]))
        app_sources << filtered_sources(filters)
        app_sources.flatten
      end
        
      # Use component generators (test_unit, etc).
      # 1.  Current application.  If APP_ROOT is defined we know we're
      #     generating in the context of this application, so search
      #     APP_ROOT/generators.
      # 2.  User home directory.  Search ~/.rubigen/generators.
      # 3.  RubyGems.  Search for gems containing /{scope}_generators folder.
      # 4.  Builtins.  None currently.
      #
      # Search can be filtered by passing one or more prefixes.
      # e.g. use_component_sources!(:rubygems) means it will also search in the following 
      # folders:
      # 5.  User home directory.  Search ~/.rubigen/rubygems_generators.
      # 6.  RubyGems.   Search for gems containing /rubygems_generators folder.
      def use_component_sources!(*filters)
        reset_sources
        new_sources = []
        if defined? ::APP_ROOT
          new_sources << PathSource.new(:root, "#{::APP_ROOT}/generators")
          new_sources << PathSource.new(:vendor, "#{::APP_ROOT}/vendor/generators")
          new_sources << PathSource.new(:plugins, "#{::APP_ROOT}/vendor/plugins/*/**/generators")
        end
        new_sources << filtered_sources(filters)
        write_inheritable_attribute(:sources, new_sources.flatten)
      end
      
      def filtered_sources(filters)
        new_sources = []
        new_sources << PathFilteredSource.new(:user, "#{Dir.user_home}/.rubigen/", *filters)
        if Object.const_defined?(:Gem)
          new_sources << GemPathSource.new(*filters)
        end
        new_sources
      end

      # Lookup knows how to find generators' Specs from a list of Sources.
      # Searches the sources, in order, for the first matching name.
      def lookup(generator_name)
        @found ||= {}
        generator_name = generator_name.to_s.downcase
        @found[generator_name] ||= cache.find { |spec| spec.name == generator_name }
        unless @found[generator_name] 
          chars = generator_name.scan(/./).map{|c|"#{c}.*?"}
          rx = /^#{chars}$/
          gns = cache.select {|spec| spec.name =~ rx }
          @found[generator_name] ||= gns.first if gns.length == 1
          raise GeneratorError, "Pattern '#{generator_name}' matches more than one generator: #{gns.map{|sp|sp.name}.join(', ')}" if gns.length > 1
        end
        @found[generator_name] or raise GeneratorError, "Couldn't find '#{generator_name}' generator"
      end

      # Convenience method to lookup and instantiate a generator.
      def instance(generator_name, args = [], runtime_options = {})
        active.lookup(generator_name).klass.new(args, full_options(runtime_options))
      end

      private
        # Lookup and cache every generator from the source list.
        def cache
          @cache ||= sources.inject([]) { |cache, source| cache + source.to_a }
        end

        # Clear the cache whenever the source list changes.
        def invalidate_cache!
          @cache = nil
        end
    end
  end

  # Sources enumerate (yield from #each) generator specs which describe
  # where to find and how to create generators.  Enumerable is mixed in so,
  # for example, source.collect will retrieve every generator.
  # Sources may be assigned a label to distinguish them.
  class Source
    include Enumerable

    attr_reader :label
    def initialize(label)
      @label = label
    end

    # The each method must be implemented in subclasses.
    # The base implementation raises an error.
    def each
      raise NotImplementedError
    end

    # Return a convenient sorted list of all generator names.
    def names(filter = nil)
      inject([]) do |mem, spec|
        case filter
        when :visible
          mem << spec.name if spec.visible?
        end
        mem
      end.sort
    end
  end


  # PathSource looks for generators in a filesystem directory.
  class PathSource < Source
    attr_reader :path

    def initialize(label, path)
      super label
      @path = File.expand_path path
    end

    # Yield each eligible subdirectory.
    def each
      Dir["#{path}/[a-z]*"].each do |dir|
        if File.directory?(dir)
          yield Spec.new(File.basename(dir), dir, label)
        end
      end
    end
    
    def ==(source)
      self.class == source.class && path == source.path
    end
  end
  
  class PathFilteredSource < PathSource
    attr_reader :filters
    
    def initialize(label, path, *filters)
      super label, File.join(path, "#{filter_str(filters)}generators")
    end
    
    def filter_str(filters)
      @filters = filters.first.is_a?(Array) ? filters.first : filters
      return "" if @filters.blank?
      filter_str = @filters.map {|filter| "#{filter}_"}.join(",")
      filter_str += ","
      "{#{filter_str}}"
    end

    def ==(source)
      self.class == source.class && path == source.path && filters == source.filters && label == source.label
    end
  end

  class AbstractGemSource < Source
    def initialize
      super :RubyGems
    end
  end

  # GemPathSource looks for generators within any RubyGem's /{filter_}generators/**/<generator_name>_generator.rb file.
  class GemPathSource < AbstractGemSource
    attr_accessor :filters
    
    def initialize(*filters)
      super()
      @filters = filters
    end
    
    # Yield each generator within rails_generator subdirectories.
    def each
      generator_full_paths.each do |generator|
        yield Spec.new(File.basename(generator).sub(/_generator.rb$/, ''), File.dirname(generator), label)
      end
    end

    def ==(source)
      self.class == source.class && filters == source.filters
    end

    private
      def generator_full_paths
        @generator_full_paths ||=
          Gem::cache.inject({}) do |latest, name_gem|
            name, gem = name_gem
            hem = latest[gem.name]
            latest[gem.name] = gem if hem.nil? or gem.version > hem.version
            latest
          end.values.inject([]) do |mem, gem|
            Dir[gem.full_gem_path + "/#{filter_str}generators/**/*_generator.rb"].each do |generator|
              mem << generator
            end
            mem
          end.reverse
      end
      
      def filter_str
        @filters = filters.first.is_a?(Array) ? filters.first : filters
        return "" if filters.blank?
        filter_str = filters.map {|filter| "#{filter}_"}.join(",")
        filter_str += ","
        "{#{filter_str}}"
      end
  end
end
