module Admin
  class CategoryRequestsController < AdminController
    def create
      ZendeskMailer.delay.request_category(current_user, params[:product_category])

      redirect_to new_admin_product_path
    end
  end
end
