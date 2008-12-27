require 'optparse'

module Rubigen
  class CLI
    attr_reader :stdout
    
    def self.execute(stdout, arguments, runtime_arguments = {})
      self.new.execute(stdout, arguments, runtime_arguments)
    end

    def execute(stdout, arguments, runtime_arguments = {})
      @stdout = stdout
      main_usage and return unless scope = arguments.shift
      scopes = scope.split(",").map(&:to_sym)
      
      runtime_arguments.merge!(:stdout => stdout, :no_exit => true)
      RubiGen::Base.logger = RubiGen::SimpleLogger.new(stdout)

      require 'rubigen/scripts/generate'
      RubiGen::Base.use_component_sources!(scopes)
      RubiGen::Scripts::Generate.new.run(arguments, runtime_arguments)
    end
    
    def main_usage
      stdout.puts <<-USAGE.gsub(/^        /, '')
      Usage: $0 scope generator [options for generator]
      USAGE
      true
    end
  end
end