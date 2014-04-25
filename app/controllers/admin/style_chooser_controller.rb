module Admin
  class StyleChooserController < AdminController
    before_action :load_market

    def show
    end

    def update
      if @market.update_attributes(style_params)
        redirect_to [:admin, @market, :style_chooser], notice: 'Styles updated'
      else
        render :show
      end
    end

    protected

    def load_market
      @market = current_user.markets.find(params[:market_id])
    end

    def style_params
      params.require(:market).permit(:background_color, :background_image, :text_color)
    end
  end
end
