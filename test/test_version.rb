require 'test/unit'
require 'rubigen'

class TestRubigenVersion < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_version

    # To change this template use File | Settings | File Templates.
    begin
      assert(RubiGen::VERSION == Rubigen::VERSION, "Expect RubiGen::VERSION to be defined" )
    rescue
      fail("Expect RubiGen::VERSION to be defined")
    end

  end
end