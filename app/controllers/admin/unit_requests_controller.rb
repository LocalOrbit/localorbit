module Admin
  class UnitRequestsController < AdminController
    def create
      ZendeskMailer.delay.request_unit(current_user, new_unit_params)

      redirect_to new_admin_product_path
    end

    private

    def new_unit_params
      params.require(:unit).permit([
        :singular, :plural, :additional_notes
      ])
    end
  end
end
