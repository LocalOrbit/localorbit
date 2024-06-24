class NonMarketDomain
  def matches?(request)
    subdomain = request.subdomains(ENV.fetch('DOMAIN').count(".")).try(:first)
    request.host != ENV.fetch('DOMAIN') && subdomain != "app" && !market_exists?(subdomain)
  end

  def market_exists?(subdomain)
    Market.where(subdomain: SimpleIDN.to_unicode(subdomain)).exists?
  end
end
