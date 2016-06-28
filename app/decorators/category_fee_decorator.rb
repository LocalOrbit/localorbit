class CategoryFeeDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def category_name
    if category.top_level_category.name == category.name
      category.top_level_category.name
    else
      "#{category.top_level_category.name} / #{category.name}"
    end
  end
end