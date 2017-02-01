class Admin::MarketStorageLocationsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_storage_location, except: [:index, :new, :create]
  before_action :find_market

  def index
    @storage_locations = StorageLocation.all.order(:name)
  end

  def show
  end

  def new
    @storage_location = StorageLocation.new
  end

  def create
    @storage_location = StorageLocation.create(storage_location_params.merge({market_id: current_market.id}))
    redirect_to admin_market_storage_locations_path, notice: "Storage Location created"
  end

  def edit
  end

  def update
    if @storage_location.update_attributes(storage_location_params)
      redirect_to admin_market_storage_locations_path, notice: "Storage Location updated"
    else
      redirect_to admin_market_storage_locations_path, alert: error
    end
  end

  def destroy

  end

  private

  def storage_location_params
    params.require(:storage_location).permit(:name)
  end

  def find_storage_location
    @storage_location = StorageLocation.find_by_id(params[:id])
  end

  def find_market
    @market = current_user.markets.find(params[:market_id])
  end
end