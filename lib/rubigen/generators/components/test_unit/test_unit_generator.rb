class TestUnitGenerator < RubiGen::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "Test#{class_name}"

      # Model, test, and fixture directories.
      m.directory File.join('test', class_path)

      # Model class, unit test, and fixtures.
      m.template 'test_unit.rb',  File.join('test', class_path, "test_#{file_name}.rb")
    end
  end

  protected
    def banner
      "Usage: #{$0} generate ModuleName"
    end
end
