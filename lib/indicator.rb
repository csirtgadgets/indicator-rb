require 'ipaddr'
require 'uri'
require 'resolv'
require 'whois'
require 'whois-parser'
require 'addressable'
require 'indicator/ipaddr'
require 'indicator/fqdn'
require 'indicator/geo'

DNS_RESOLVER = Resolv::DNS.new

#require 'email_validator'

module StringIndicatorExtensions
  def itype
    return 'url' if _url(self)
    return 'email' if _email?(self)
    return 'fqdn' if _fqdn(self)
    return 'ipv4' if _ipv4(self)
    return 'ipv6' if _ipv6(self)
    return 'md5' if _md5(self)
    return 'sha1' if _sha1(self)
    return 'sha256' if _sha256(self)
    return 'sha512' if _sha512(self)
    return 'cc' if _cc(self)
    'asn' if _asn(self)
  end

  def ip?
    %w(ipv4 ipv6).include? self.itype.to_s
  end

  def indicator?
    return false if itype.nil?
    return true if ip?
    return true if hash?
    return true if %w(fqdn url email).include? itype
    false
  end

  def prefix?
    return unless ip?
    self.to_ip.prefix?
  end

  def hash?
    %w(md5 sha1 sha256 sha512).include? self.itype.to_s
  end

  def url?
    self.itype == 'url'
  end

  def fqdn?
    itype == 'fqdn'
  end

  def email?
    itype == 'email'
  end

  def cc?
    itype == 'cc'
  end

  def indicator_from_string
    indicators = []
    self.split(' ').each do |w|
      w.gsub!(/[\.\?]$/, '')
      indicators.push(w) if w.indicator?
    end
    indicators
  end

  def whois
    return unless self
    return unless %w(fqdn ipv4 ipv6 url).include? self.itype.to_s

    r = self
    if itype == 'fqdn'
      r = self.split('.').last(2).join('.')
    end

    if self.itype == 'url'
      r = URI(self).host
      r = r.split('.').last(2).join('.')
    end

    begin
      r = Whois.whois(r).parser
    rescue Timeout::Error
      return
    end
    r
  end

  def created_at
    begin
      self.whois.created_on if self.fqdn?
      self.whois.regdate if self.ip?
    rescue
      return
    end
  end

  def updated_at
    begin
      self.whois.updated_on
    rescue
      return
    end
  end

  private
    def _ipv4(i)
      begin
        x = i.to_ip
      rescue
        return false
      end
      x.ipv4?
    end

    def _ipv6(i)
      begin
        x = i.to_ip
      rescue
        return false
      end
      x.ipv6?
    end

    def _fqdn(i)
      /^((xn\-\-)?(\-\-)?[a-zA-Z0-9\-_]+(\-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}(\-\-p1ai)?$/.match(i)
    end

    def _url(i)
      begin
        x = Addressable::URI.parse(i)
      rescue
        return false
      end
      (x.scheme.eql?('http') || x.scheme.eql?('https'))
    end

    def _email?(i)
      # https://github.com/balexand/email_validator/blob/master/lib/email_validator.rb
      /\A\s*([^@\s]{1,64})@((?:[-\p{L}\d]+\.)+\p{L}{2,})\s*\z/i.match(i)
    end

    def _md5(i)
      /^[a-fA-F0-9]{32}$/.match(i)
    end

    def _sha1(i)
      /^[a-fA-F0-9]{40}$/.match(i)
    end

    def _sha256(i)
      /^[a-fA-F0-9]{64}$/.match(i)
    end

    def _sha512(i)
      /^[a-fA-F0-9]{128}$/.match(i)
    end

    def _asn(i)
      return false if i.upcase == 'AS'
      /^ASN?(?:[1-9]\d*|0)?(?:\.\d+)?$/.match(i.upcase)
    end

    # TODO? https://datahub.io/core/country-codes#data
    def _cc(i)
      return false if %w(url uri md5 cc).include? i
      /^[A-Z]{2,3}$/.match(i.upcase)
    end
end

String.send(:include, StringIndicatorExtensions)