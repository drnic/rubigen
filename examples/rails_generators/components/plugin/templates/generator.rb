class <%= class_name %>Generator < RubiGen::NamedBase
  def manifest
    record do |m|
      # m.directory "lib"
      # m.template 'README', "README"
    end
  end
end
