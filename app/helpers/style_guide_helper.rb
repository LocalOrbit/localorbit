module StyleGuideHelper
  def centered_column(css_class = '', &block)
    raw "<div style='text-align: center'><div class='column #{css_class}'>" + capture(&block) + "</div></div>"
  end
end
