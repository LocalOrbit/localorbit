module Admin
  class StyleChooserController < AdminController
    before_action :find_market

    def show
    end

    def update
      error = validate_colors(style_params)
      if error.length == 0 && @market.update_attributes(style_params)
        redirect_to [:admin, @market, :style_chooser], notice: "Styles updated"
      else
        redirect_to [:admin, @market, :style_chooser], alert: error
      end
    end

    protected

    def style_params
      params.require(:market).permit(:background_color, :background_image, :text_color)
    end

    def validate_colors(style_params)
      error = ''
      if style_params["text_color"] !~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i || style_params["background_color"] !~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i
        error ='Invalid color selection'
      end

      return error
    end
  end
end
