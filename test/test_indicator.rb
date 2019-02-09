require 'minitest/autorun'
require 'indicator'
require 'pp'

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

    assert 'csirtgadgets.com'.mx
    assert 'csirtgadgets.com'.ns

    assert 'https://csirtg.io'.rdata

    assert 'https://csirtg.io'.cc == 'US'

    assert '192.168.1.0/24'.to_ip

    assert 'wes@csirtgadgets.com'.itype == 'email'

    assert '10.233.18.116:43880'.itype != 'ip'

    assert not('http://medhurstanderson.orgkulaswisozk.comjakubowski.name'.ip?)
  end

  def test_indicator_from_string
    indicators = 'this is an example.com of an indicator that yields 192.168.1.1'.indicator_from_string
    assert indicators.size == 2
  end
end