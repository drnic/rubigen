require File.dirname(__FILE__) + '/../scripts'

module RubiGen::Scripts
  class Destroy < Base
    mandatory_options :command => :destroy
    
    protected
    def usage_message
      usage = "\nInstalled Generators\n"
      RubiGen::Base.sources.each do |source|
        label = source.label.to_s.capitalize
        names = source.names
        usage << "  #{label}: #{names.join(', ')}\n" unless names.empty?
      end

      usage << <<-end_blurb

This script will destroy all files created by the corresponding 
script/generate command. For instance, script/destroy test_unit create_post
will delete the appropriate test_create_post.rb file in /test.
      
For instructions on finding new generators, run script/generate
end_blurb
      return usage
    end
  end
end
