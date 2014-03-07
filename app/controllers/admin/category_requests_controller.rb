module Admin
  class CategoryRequestsController < AdminController
    def create
      ZendeskMailer.request_category(current_user.email, current_user.name, new_category_params[:product_category])
                   .deliver

      redirect_to new_admin_product_path
    end

    private

    def new_category_params
      params.permit([:product_category])
    end
  end
end
