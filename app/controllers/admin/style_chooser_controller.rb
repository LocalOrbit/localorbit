module Admin
  class StyleChooserController < AdminController
    before_action :find_market

    def show
    end

    def update
      if @market.update_attributes(style_params)
        redirect_to [:admin, @market, :style_chooser], notice: "Styles updated"
      else
        render :show
      end
    end

    protected

    def style_params
      params.require(:market).permit(:background_color, :background_image, :text_color)
    end
  end
end
