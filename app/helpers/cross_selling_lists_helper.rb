module CrossSellingListsHelper

  def status_help_text
    # Two main criteria - creator and locked:
    if @cross_selling_list.locked? then
      # Locked means just that.  Display the message but nothing else
      current_status = "This list has been <span style='font-weight:600'>#{@cross_selling_list.translate_status(@cross_selling_list.status)}</span>. "
      product_visibility = "You may still edit product visibility for this list, but products will only appear in your catalog if the Publisher re-enables the list."

    else
      # Otherwise, content is subject to whether the user is the list creator
      if @cross_selling_list.creator then
        visibility_target = "your subscribers'"
        visibility_condition += "unless they mark them as inactive."
      else
        visibility_target = "your"
        visibility_condition += "unless you mark them as inactive."
      end

      # These are the same regardless of creator status
      current_status = "This list currently has a status of <span style='font-weight:600'>#{@cross_selling_list.translate_status(@cross_selling_list.status)}</span>, but you may change it here. "
      product_visibility = "Items on lists whose status is '#{@cross_selling_list.translate_status("Published")}' will appear in #{visibility_target} product catalog " + visibility_condition
    end
    
    raw(current_status + product_visibility)
  end

  def list_name(form_instance)
    if @cross_selling_list.locked? then
      raw("<span style='font-weight:600'>#{@cross_selling_list.name}</span>")
    else
      form_instance.text_field :name, class: "column--full"
    end
  end
end
