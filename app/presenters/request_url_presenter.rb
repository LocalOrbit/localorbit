class RequestUrlPresenter
  attr_reader :base_url

  def initialize(request)
    @base_url = request.base_url
  end
end
