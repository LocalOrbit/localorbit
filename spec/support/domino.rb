module Dom
  class CategorySelect < Domino
    selector "#product_category_id_chosen"

    def click
      page.find("a", text: "Select a Category").click
    end

    def visible_options
      node.all(".active-result").map(&:text)
    end

    def visible_option(text)
      node.find("li", text: text)
    end

    def type_search(term)
      node.find(".chosen-search input").set(term)
    end
  end
end
