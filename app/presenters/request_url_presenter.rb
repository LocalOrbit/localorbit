class RequestUrlPresenter
  attr_reader :base_url

  def initialize(request)
    if(Rails.env.development?)
      @base_url = request.base_url.sub(":3000", ":3500") #yoloswagg
    else
      @base_url = request.base_url
    end
  end
end
