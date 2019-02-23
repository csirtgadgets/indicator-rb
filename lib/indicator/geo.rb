require 'resolv'
require 'maxminddb'

GEO_PATHS = %w(
  /var/lib/GeoIP
  /usr/local/var/GeoIP
  /usr/local/share/GeoIP
  /usr/share/GeoIP
)

GEO_PATHS.each do |p|
  next unless File.directory?(p)
  GEOIP_PATH_CONST = p
  break
end

GEOIP_ASN = MaxMindDB.new("#{GEOIP_PATH_CONST}/GeoLite2-ASN.mmdb")
GEOIP_CC = MaxMindDB.new("#{GEOIP_PATH_CONST}/GeoLite2-City.mmdb")

module StringGeoExtensions
  def asn(all=false)
    r = lookup(true) || return
    return r.to_hash['autonomous_system_number'] unless all
    {
        asn: r.to_hash['autonomous_system_number'],
        asn_desc: r.to_hash['autonomous_system_organization'].upcase
    }
  end

  def asn_desc
    r = lookup(true) || return
    return unless r.to_hash['autonomous_system_organization']
    r.to_hash['autonomous_system_organization'].upcase
  end

  def cc(all=false)
    r = lookup || return
    return unless r.country.iso_code
    return r.to_hash if all
    r.country.iso_code.upcase
  end

  def city(all=false)
    r = lookup || return
    return unless r.city
    return r.to_hash if all
    r.city.name
  end

  def location
    r = lookup || return
    return unless r.city
    {
        city: r.city.name,
        region: r.subdivisions[0].name,
        cc: r.country.iso_code

    }

  end

  private
    def _resolve(i)
      begin
        if i.itype == 'url'
          i = URI(i).host
        end
        host = DNS_RESOLVER.getaddress(i)
      rescue Resolv::ResolvError
        return
      end

      host.to_s
    end

    def lookup(asn=false)
      if self.ip?
        r = self
      else
        r = _resolve(self)
      end

      return unless r

      # begin
      #   return unless self.ip?
      #   r = self
      # rescue
      #   r = _resolve(self)
      #   return unless r
      # end

      r = (asn)? GEOIP_ASN.lookup(r) : GEOIP_CC.lookup(r)
      return unless r.found?
      r
    end
end

String.send(:include, StringGeoExtensions)

module IPAddrGeoExtensions
  include StringGeoExtensions

  private
  def lookup(asn=false)
    r = (asn)? GEOIP_ASN.lookup(self.to_s) : GEOIP_CC.lookup(self.to_s)
    return unless r.found?
    r
  end
end

IPAddr.send(:include, IPAddrGeoExtensions)