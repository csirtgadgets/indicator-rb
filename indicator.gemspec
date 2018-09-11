Gem::Specification.new do |s|
  s.name        = 'indicator'
  s.version     = '0.0a1'
  s.date        = '2018-08-31'
  s.summary     = 'Indicators made easy'
  s.description = 'Indicators made easy'
  s.authors     = ['Wes Young']
  s.email       = 'wes@csirtgadgets.com'
  s.files       = %w(lib/indicator.rb lib/indicator/geo.rb lib/indicator/ipaddr.rb lib/indicator/fqdn.rb)
  s.homepage    =
      'http://rubygems.org/gems/indicator'
  s.license       = 'MPL2'

  %w(email_address whois whois-parser).each do |d|
    s.add_runtime_dependency d
  end
end
