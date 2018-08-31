require 'ipaddr'
require 'uri'
require 'indicator/geo'
require 'indicator/ipaddr'
#require 'email_validator'

module StringIndicatorExtensions
  def itype
    return 'ipv4' if _ipv4(self)
    return 'ipv6' if _ipv6(self)
    return 'fqdn' if _fqdn(self)
    return 'url' if _url(self)
    return 'email' if _email?(self)
    return 'md5' if _md5(self)
    return 'sha1' if _sha1(self)
    return 'sha256' if _sha256(self)
    return 'sha512' if _sha512(self)
    'asn' if _asn(self)
  end

  def ip?
    %(ipv4 ipv6).include? self.itype
  end

  def hash?
    %(md5 sha1 sha256 sha512).include? self.itype
  end

  def url?
    self.itype == 'url'
  end

  private
    def _ipv4(i)
      begin
        x = IPAddr.new(i)
      rescue
        return false
      end
      x.ipv4?
    end

    def _ipv6(i)
      begin
        x = IPAddr.new(i)
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
        x = URI.escape(i)
        x = URI(x)
      rescue URI::InvalidURIError
        return false
      end
      (x.scheme.eql?('http') || x.scheme.eql?('https'))
    end

    def _email?(i)
      EmailValidator.valid?(i)
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
end

String.send(:include, StringIndicatorExtensions)