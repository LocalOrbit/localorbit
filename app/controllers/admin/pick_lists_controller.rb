class Admin::PickListsController < AdminController
  def show
    # The PickListPresenter will limit the results to
    # only things visible to the current user
    @delivery   = Delivery.find(params[:id]).decorate
    @pick_lists = PickListPresenter.build(current_user, @delivery)
    render_404 if @pick_lists.empty?
  end
end
