module SocialMediaHelper 
  
  def facebook_like(facebook_handle) 
    if !(facebook_handle == '' || facebook_handle == nil) then 
      if facebook_handle.index('facebook.com/') == nil then
        massaged_handle = facebook_handle
      else
        massaged_handle = facebook_handle.slice(facebook_handle.index('facebook.com/')+13..-1) 
      end
      
      prepared_url = "https://www.facebook.com/#{massaged_handle}"
      
      if check_link(prepared_url) != 404 then
        render partial: "shared/facebook", locals: { f: prepared_url }
      end 
      
    else 
      # If facebook_handle is null or blank then skip it... 
    end 
  end 
  
  private
  
  def check_link(prepared_url)
    if false then 
      uri = URI(prepared_url)
      request = Net::HTTP.new uri.host
      response= request.request_head uri.path
      return response.code.to_i    
    else
      # this isn't working (at least locally), but I like the idea of a confirmation
      200
    end
  end
end