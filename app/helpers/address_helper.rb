module AddressHelper
  ExcludedUsStates = %w()
  ExcludedCaProvinces = %w()

  def options_for_state_select
    return @options_for_state_select if @options_for_state_select

    us_states = Country["US"].states.reject do |s| ExcludedUsStates.include?(s) end
    ca_provinces = Country["CA"].states.reject do |s| ExcludedCaProvinces.include?(s) end

    to_option = -> ((key,state)) { [state["name"], key] }
    @options_for_state_select = us_states.map(&to_option) + ca_provinces.map(&to_option)
  end

end
