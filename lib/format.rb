module Format
  include ActionView::Helpers::NumberHelper
  extend self
  
  def quantity(value)
    number_with_delimiter(number_with_precision(value, strip_insignificant_zeros:true))
  end
end
