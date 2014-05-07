module Admin
  class CategoryRequestsController < AdminController
    def create
      ZendeskMailer.request_category(current_user.email, current_user.name, params[:product_category]).
                    deliver

      redirect_to new_admin_product_path
    end
  end
end
