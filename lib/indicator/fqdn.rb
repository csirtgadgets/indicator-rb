
module StringFQDNExtensions
  def resolve_ip
    if self.itype == 'url'
      i = URI(self).host
    else
      i = self
    end

    begin
      host = DNS_RESOLVER.getaddress(i)
    rescue Resolv::ResolvError => e
      return
    end

    host.to_s
  end
end

String.send(:include, StringFQDNExtensions)

module StringFQDNExtensions
  def ns
    i = to_fqdn

    # get last two for the FQDN
    i = i.split('.').pop(2).join('.') if i.count('.') > 1

    begin
      r = DNS_RESOLVER.getresources(i, Resolv::DNS::Resource::IN::NS)
    rescue Resolv::ResolvError
      return
    end

    return unless r.length > 0
    r.map{|rr| rr.name.to_s unless /root-servers.net/.match(rr.name.to_s) }
  end

  def rdata
    begin
      r = DNS_RESOLVER.getaddresses(to_fqdn())
    rescue Resolv::ResolvError
      return
    end

    return unless r.length > 0
    r.map{|rr| rr.to_s }
  end

  def mx
    i = to_fqdn

    # get last two for the FQDN
    i = i.split('.').pop(2).join('.') if i.count('.') > 1

    begin
      r = DNS_RESOLVER.getresources(i, Resolv::DNS::Resource::IN::MX)
    rescue Resolv::ResolvError
      return
    end

    return unless r.length > 0
    r.map{|r| r.exchange.to_s unless /root-servers.net/.match(r.exchange.to_s) }
  end

  private
    def to_fqdn
      i = self
      if i.start_with? 'http'
        i = URI.escape(i)
        i = URI(i)
        i = i.host
      end

      if /@/.match(i)
        i = i.split('@').pop(1)[0]
      end
      i
    end
end

String.send(:include, StringFQDNExtensions)