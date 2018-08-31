require 'minitest/autorun'
require 'indicator'

# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/minitest/unit/rdoc/MiniTest.html

@remote = 'https://localhost'
@token = '1234444'

class TestIndicator < Minitest::Test
  def setup
  end

  def test_indicator
    assert '192.168.1.1'.itype == 'ipv4'
    assert '192.168.1.1'.ip?

    assert '128.205.1.1'.cc == 'US'
  end
end