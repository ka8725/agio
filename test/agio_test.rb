require 'test_helper'

class AgioTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Agio::VERSION
  end
end
