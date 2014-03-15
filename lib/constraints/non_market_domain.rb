class NonMarketDomain
  def matches?(request)
    subdomain = request.subdomains(Figaro.env.domain.count('.'))
    request.domain != Figaro.env.domain && !market_exists?(subdomain)
  end

  def market_exists?(subdomain)
    Market.where(subdomain: subdomain).exists?
  end
end
