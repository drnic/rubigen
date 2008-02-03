require File.dirname(__FILE__) + '/../scripts'

module RubiGen::Scripts
  class Update < Base
    mandatory_options :command => :update

    protected
      def banner
        "Usage: #{$0} [options] generator"
      end
  end
end
