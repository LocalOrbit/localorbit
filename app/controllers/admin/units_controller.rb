module Admin
  class UnitsController < AdminController
    def request_new
      ZendeskMailer.request_unit(current_user.email, current_user.name, new_unit_params)
                   .deliver

      redirect_to new_admin_product_path
    end

    private

    def new_unit_params
      params.permit([
        :singular, :plural, :additional_notes
      ])
    end
  end
end
