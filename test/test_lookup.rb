require File.dirname(__FILE__) + "/test_generator_helper"

class TestLookup < Test::Unit::TestCase
  include RubiGen
  
  def setup
    Base.reset_sources
  end
  
  def test_lookup_component
    assert_nothing_raised(GeneratorError, "Could not find install_rubigen_scripts generator") { Base.lookup('install_rubigen_scripts') }
  end
  
  def test_lookup_unknown_component
    assert_raise(GeneratorError, "Should not find generator") { Base.lookup('dummy') }
  end
  
  # There are 5 sources of generators
  # * HOME/.rubigen/generators
  # * APP_ROOT/generators
  # * APP_ROOT/vendor/generators
  # * APP_ROOT/vendor/plugins/.../
  # * RubyGems internal /generators folder
  # 
  # Note, this differs from Rails generator:
  # * RubyGems whose name is suffixed with _generator are not loaded (e.g. ajax_scaffold_generator)
  def test_sources
    sources = Base.sources
    assert(sources.find do |source|
      source.path =~ /\.rubigen\/generators$/ if source.respond_to? :path
    end, "One source should be HOME/.rubigen/generators")

    assert(sources.find do |source|
      source.path =~ /#{::APP_ROOT}\/generators$/ if source.respond_to? :path
    end, "One source should be APP_ROOT/generators")

    assert(sources.find do |source|
      source.path =~ /#{::APP_ROOT}\/vendor\/generators$/ if source.respond_to? :path
    end, "One source should be APP_ROOT/vendor/generators")

    assert(sources.find do |source|
      source.path =~ /#{::APP_ROOT}\/vendor\/plugins\/.*\/generators$/ if source.respond_to? :path
    end, "One source should be APP_ROOT/vendor/plugins/.../generators")
    
    assert(sources.find do |source|
      source.is_a?(GemPathSource)
    end, "One source should be RubyGems containing generators")

  end
  
  def test_unscoped_gem_path
    source = GemPathSource.new
    assert_equal("", source.send(:filter_str))
  end

  def test_scoped_gem_path
    source = GemPathSource.new("rubygems")
    assert_equal("{rubygems_,}", source.send(:filter_str))
  end

  def test_alternate_scoped_gem_path
    source = GemPathSource.new(:rubygems, :ruby)
    assert_equal("{rubygems_,ruby_,}", source.send(:filter_str))
  end

  def test_scoped_gem_path_using_array
    source = GemPathSource.new([:rubygems, :ruby])
    assert_equal("{rubygems_,ruby_,}", source.send(:filter_str))
  end
  
  def test_use_component_sources_without_scope
    Base.use_component_sources!
    gem_path_source = Base.sources.find { |source| source.is_a?(GemPathSource) }
    assert_not_nil(gem_path_source, "Where is the GemPathSource?")
    assert_equal("", gem_path_source.send(:filter_str))
  end
  
  def test_use_component_sources_with_scope
    Base.use_component_sources! :rubygems, :ruby
    gem_path_source = Base.sources.find { |source| source.is_a?(GemPathSource) }
    assert_not_nil(gem_path_source, "Where is the GemPathSource?")
    assert_equal("{rubygems_,ruby_,}", gem_path_source.send(:filter_str))
    user_path_source = Base.sources.find { |source| source.is_a?(PathFilteredSource) }
    assert_not_nil(user_path_source, "Where is the PathFilteredSource?")
    assert_match(/\.rubigen\/\{rubygems_,ruby_,\}generators/, user_path_source.path)
  end
  
  def test_use_application_sources
    Base.use_application_sources!
    expected_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. app_generators]))
    builtin_source = Base.sources.find { |s| s.path == expected_path if s.respond_to?(:path) }
    assert_not_nil(builtin_source, "Cannot find builtin generators")
    assert_nothing_raised(GeneratorError) do
      generator = Base.lookup('ruby_app')
    end
  end

  def test_use_application_sources_with_scope
    Base.use_application_sources! :rubygems, :newgem
    gem_path_source = Base.sources.find { |source| source.is_a?(GemPathSource) }
    assert_not_nil(gem_path_source, "Where is the GemPathSource?")
    assert_equal("{app_,rubygems_,newgem_,}", gem_path_source.send(:filter_str))
    user_path_source = Base.sources.find { |source| source.is_a?(PathFilteredSource) }
    assert_not_nil(user_path_source, "Where is the PathFilteredSource?")
    assert_match(/\.rubigen\/\{app_,rubygems_,newgem_,\}generators/, user_path_source.path)
  end
end