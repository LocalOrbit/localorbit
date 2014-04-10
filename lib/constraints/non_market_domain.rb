class NonMarketDomain
  def matches?(request)
    subdomain = request.subdomains(Figaro.env.domain.count(".")).try(:first)
    request.host != Figaro.env.domain && subdomain != "app" && !market_exists?(subdomain)
  end

  def market_exists?(subdomain)
    Market.where(subdomain: SimpleIDN.to_unicode(subdomain)).exists?
  end
end
