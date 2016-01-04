module SocialMediaHelper 
  
  def facebook_like(facebook_handle) 
    if !(facebook_handle == '' || facebook_handle == nil) then 
      massaged_handle = strip_detritus(facebook_handle, 'facebook.com/')
      prepared_url = "https://www.facebook.com/#{massaged_handle}"
      
      render partial: "shared/facebook", locals: { f: prepared_url }
      
    else 
      # If facebook_handle is null or blank then skip it... 
    end 
  end 
  
  def twitter_button(twitter_handle)
    if !(twitter_handle == '' || twitter_handle == nil) then 
      massaged_handle = strip_detritus(twitter_handle, 'twitter')
      prepared_url = "https://www.twitter.com/#{massaged_handle}"
      
      render partial: "shared/twitter", locals: { f: twitter_handle }
    end
  end
  
  private
  
  def strip_detritus(source, fulcrum)
    if source.index(fulcrum) != nil
      remove_fulcrum = fulcrum.length.to_int
      source.slice(source.index(fulcrum)+remove_fulcrum..-1)
    else
      source
    end
  end
  
end