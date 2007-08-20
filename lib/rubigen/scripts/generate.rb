require File.dirname(__FILE__) + '/../scripts'

module RubiGen::Scripts
  class Generate < Base
    mandatory_options :command => :create
  end
end
