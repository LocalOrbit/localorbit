class Admin::PickListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate
    @pick_list = PickListPresenter.build(current_user, current_organization, @delivery)
  end
end
