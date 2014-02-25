module Dom
  class TypeAhead < Domino
    def select_text
      raise "Implement in subclass"
    end

    def click
      node.find("a", text: select_text).click
    end

    def visible_options
      node.all(".active-result").map(&:text)
    end

    def visible_option(text)
      node.find("li", text: text)
    end

    def search_field
      node.find(".chosen-search input")
    end

    def type_search(term)
      search_field.set(term)
    end

  end

  class CategorySelect < TypeAhead
    selector "#product_category_id_chosen"

    def select_text
      "Click and type to search for a Category"
    end
  end


  class LotRow < Domino
    selector "#inventory_table tbody tr.lot"

    def editable?
      node.all("input").present?
    end

    def click
      node.click
    end

    def number
      node.find(".number").text
    end

    def good_from
      node.find(".good_from").text
    end

    def expires_at
      node.find(".expires_at").text
    end

    def quantity
      node.find(".quantity").text
    end

    def inputs
      node.all("input")
    end
  end

  class NewLotForm < LotRow
    selector "#inventory_table thead tr.lot"

    def quantity
      node.find("#lot_quantity")
    end

    def expires_at
      node.find("#lot_expires_at")
    end
  end

  class ProductForm < Domino
    selector "form.product"

    def organization_field
      node.find('#product_organization_id')
    end

    def name
      node.find('#product_name')
    end

    def category
      node.find('#product_category_id')
    end
  end

  class DatePicker < Domino
    selector ".ui-datepicker"

    def self.open(field_id)
      Capybara.current_session.find_field(field_id).click
      first
    end

    def click_next
      node.find('a[title="Next"]').click
    end

    def click_day(day)
      node.find('.ui-datepicker-calendar').click_link(day)
    end
  end

  module Admin
    class OrganizationLocation < Domino
      selector "tbody tr"

      def name_and_address
        cells[0].text
      end

      def telephone
        cells[1].text
      end

      def default_billing
        cells[2].find("input")
      end

      def default_shipping
        cells[3].find("input")
      end

      def remove!
        cells[4].find("input").set(true)
        click_button "Remove Checked"
      end

      def default_billing?
        default_billing["checked"]
      end

      def default_shipping?
        default_shipping["checked"]
      end

      def mark_default_billing
        default_billing.set(true)
      end

      def mark_default_shipping
        default_shipping.set(true)
      end

      def name
        cells[0].find("a").text
      end

      def edit
        click_link name
      end

      private

      def cells
        @cells ||= @node.all("td")
      end
    end
  end

  class Product < Domino
    selector ".product"

    attribute :name
    attribute :organization_name
  end

  class ProductFilter < Domino
    selector "#product-filter"

    def self.filter_by_seller(org)
      first.click_link(org.name)
    end

    def self.filter_by_category(category)
      first.click_link(category.name)
    end

    def self.current_seller
      first.find("#product-filter-organization-name > .current").text
    end

    def self.current_category
      first.find("#product-filter-category > .current").text
    end
  end
end
