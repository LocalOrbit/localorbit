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

  class Select < Domino
    selector "select"

    def has_option?(text)
      all("option").map(&:text).include?(text)
    end
  end

  class CategorySelect < TypeAhead
    selector "#product_category_id_chosen"

    def select_text
      "Click and type to search for a Category"
    end
  end

  class EditableTableRow < Domino
    def editable?
      node.all('input[type="submit"]').present?
    end

    def click
      node.trigger("click")
    end

    def inputs
      node.all("input")
    end
  end

  class LotRow < EditableTableRow
    selector "#inventory_table tbody tr.lot"

    def click_number
      node.find(".number").click
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
  end

  class MarketSellers < Domino
    selector ".market-sellers li"

    def name
      node.find("a").text
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

  class PricingRow < EditableTableRow
    selector "#pricing_table tbody tr.price"

    def click_buyer
      node.find(".buyer").click
    end

    def market
      node.find(".market").text
    end

    def buyer
      node.find(".buyer").text
    end

    def min_quantity
      node.find(".min-qty").text
    end

    def net_price
      node.find(".net-price").text
    end

    def sale_price
      node.find(".sale-price").text
    end

    def check_delete
      node.find('.delete input').set(true)
    end

    def click_delete
      node.find_link("Delete").click
    end

    def click_edit
      node.find_link("Edit").click
    end
  end

  class NewPricingForm < PricingRow
    selector ".add-price"

    def min_quantity
      node.find("#price_min_quantity")
    end

    def sale_price
      node.find("#price_sale_price")
    end

    def net_price
      node.find("#price_net_price")
    end
  end


  class DatePicker < Domino
    selector ".ui-datepicker"

    def self.open(field_id)
      Capybara.current_session.find_field(field_id).click
      first
    end

    def click_next
      node.find('a[title="Next"]').trigger("click")
    end

    def click_day(day)
      node.find('.ui-datepicker-calendar').click_link(day)
    end
  end

  module Admin
    module Financials
      class InvoiceRow < Domino
        selector ".invoice-row"

        def self.select_all
          page.find('.select-all').click
        end

        attribute :order_number
        attribute :buyer
        attribute :order_date
        attribute :due_date
        attribute :amount

        def send_invoice
          node.click_link("Send Invoice")
        end

        def check_row
          node.find('input[type="checkbox"]').set(true)
        end

        def enter_receipt
          node.click_link("Enter Receipt")
        end
      end

      class PaymentRow < Domino
        selector ".payment-row"

        attribute :date
        attribute :order_number
        attribute :payment_method
        attribute :amount
      end
    end

    class DeliverySchedule < Domino
      selector "tbody tr"

      def weekday
        delivery_text[/^[^,]+/]
      end

      def cutoff
        delivery_text[/order cutoff ([0-9]+) hours before delivery/]
      end

      def delivery_text
        node.find('.delivery-text').text
      end

      def delivery_address
        node.find('.address').text
      end

      def delivery_time
        node.find('.delivery-time').text
      end

      def pickup_time
        node.find('.pickup-time').text
      end

      def click_delete
        node.find_link('Delete').click
      end
    end

    class OrganizationForm < Domino
      selector "form.organization"

      def name
        node.find("#organization_name").value
      end
    end

    class OrderRow < Domino
      selector ".order-row"

      attribute :order_number
      attribute :amount_owed
      attribute :delivery_status
      attribute :buyer_status
    end

    class OrderSummaryRow < Domino
      selector ".order-summary-row"

      attribute :gross_total
      attribute :discount
      attribute :transaction_fees
      attribute :payment_processing
      attribute :net_sale
      attribute :delivery_status
      attribute :payment_status
    end

    class OrganizationLocation < Domino
      selector "tbody tr"

      def name_and_address
        cells[1].text
      end

      def default_billing
        cells[3].find("input")
      end

      def default_shipping
        cells[4].find("input")
      end

      def remove!
        cells[0].find("input").set(true)
        click_button "Delete Selected"
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
        cells[1].find("a").text
      end

      def edit
        click_link name
      end

      private

      def cells
        @cells ||= @node.all("td")
      end
    end

    class PickListItem < Domino
      selector ".pick-list-item"

      attribute :name
      attribute :total_sold
      attribute :buyer
      attribute :breakdown

    end

    class PackListItem < Domino
      selector ".pack-list-item"

      attribute :name
      attribute :quantity
      attribute :units
      attribute :seller
      attribute :total_price
    end

    class IndividualPackListItem < Domino
      selector ".individual-pack-list-item"

      attribute :name
      attribute :total_sold
      attribute :units
      attribute :delivery
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

      def who_story
        node.find('#product_who_story').value
      end

      def how_story
        node.find('#product_how_story').value
      end

      def locations
        node.all("#product_location_id option").map(&:text)
      end

      def selected_location
        node.find("#product_location_id").value
      end

      def location
        node.find('#product_location_id')
      end

      def seller_info
        node.find('#seller_info')
      end
    end

    class ProductDelivery < Domino
      selector ".product-delivery-schedule"

      attribute :weekday

      def description
        node.find("label").text
      end

      def checked?
        node.find("input").checked? || false
      end

      def check!
        node.find("input").set(true)
      end

      def uncheck!
        node.find("input").set(false)
      end
    end

    class LocationForm < Domino
      selector ".edit_location, .new_location"

      def location_name
        node.find("#location_name")
      end

      def address
        node.find("#location_address")
      end

      def city
        node.find("#location_city")
      end

      def state
        node.find("#location_state")
      end

      def selected_state
        state.find('option[selected]')
      end

      def zip
        node.find("#location_zip")
      end
    end

    class SoldItemRow < Domino
      selector ".sold-item"

      attribute :order_number
      attribute :order_date
      attribute :buyer
      attribute :seller
      attribute :product
      attribute :market
      attribute :quantity
      attribute :total_price
      attribute :unit_price
      attribute :delivery_status
      attribute :buyer_payment_status
      attribute :seller_payment_status

      def select
        node.find("input").set(true)
      end
    end
  end

  module Cart
    class SellerGroup < Domino
      selector ".item-group"
      attribute :seller

      def has_product_row?(content)
        node.has_selector?(".cart_item", text: content)
      end
    end

    class Item < Domino
      selector ".cart_item"

      attribute :name
      attribute :description

      def unit_prices
        node.all(".unit-price").map(&:text)
      end

      def quantity
        node.find(".quantity")
      end

      def price_for_quantity
        node.find(".price-for-quantity")
      end

      def price
        node.find(".price")
      end

      def quantity_field
        node.find_field "quantity"
      end

      def set_quantity(n)
        quantity_field.set(n)
      end

      def remove_link
        node.find(".icon-clear")
      end

      def remove!
        node.find(".icon-clear").trigger("click")
      end
    end

    class Totals < Domino
      selector "#totals"

      def subtotal
        node.find(".subtotal")
      end

      def total
        node.find(".total")
      end

      def delivery_fees
        node.find(".delivery_fees")
      end
    end
  end

  class Product < Domino
    selector ".product"

    attribute :name
    attribute :organization_name
    attribute :pricing
    attribute :quantity

    def open_who_story
      node.click_link organization_name
    end

    def open_how_story
      node.click_link "How"
    end

    def prices
      node.all(".tiers li").map do |tier|
        tier.find(".unit-price").text
      end
    end
  end

  class ProductFilter < Domino
    selector "#product-filter"

    def self.filter_by_seller(org)
      first.find("#product-filter-organization").click_link(org.name)
    end

    def self.filter_by_category(category)
      categories.click_link(category.name)
    end

    def self.categories
      first.find("#product-filter-category")
    end

    def self.current_seller
      first.find("#product-filter-organization > .current").text
    end

    def self.current_category
      first.find("#product-filter-category > .current").text
    end
  end

  class ProductRow < Domino
    selector ".product-row"

    attribute :market
    attribute :name
    attribute :pricing
    attribute :seller
    attribute :stock

    def click_delete
      node.click_link "Delete"
    end
  end

  class CartLink < Domino
    selector "header .cart"

    def count
      node.find(".counter")
    end
  end

  class BankAccount < Domino
    selector ".bank-account"

    attribute :bank_name
    attribute :account_number
    attribute :account_type
    attribute :verified

    def verfied?
      verified == "Verified"
    end
  end

  module Buying
    class DeliveryChoice < Domino
      selector "#deliveries .delivery"

      attribute :type
      attribute :date
      attribute :time_range
      attribute :fn
      attribute :street_address
      attribute :locality
      attribute :region
      attribute :postal_code

      def description
        "#{type} #{date} #{time_range}"
      end

      def self.submit
        within("#deliveries") do
          click_button "Start Shopping"
        end
      end

      def has_location_select?
        node.all('select').size == 1
      end

      def choose!
        node.find("input[type=radio]").set(:checked)
        self.class.submit
      end
    end

    class CartItem < Domino
    end

    class SelectedDelivery < Domino
      selector ".selected-delivery"

      attribute :display_date
      attribute :time_range
      attribute :delivery_type
      attribute :location_name
      attribute :location_address

      def click_change
        click_link "Change"
      end
    end
  end

  module Order
    class ItemRow < Domino
      selector ".order-item-row"

      attribute :name
      attribute :quantity
      attribute :price
      attribute :discount
      attribute :total
      attribute :payment_status
      attribute :delivery_status
    end
  end

  module Dashboard
    class OrderRow < Domino
      selector ".order-row"

      attribute :order_number
      attribute :placed_on
      attribute :total
      attribute :delivery
      attribute :payment
      attribute :order_date
      attribute :delivery_status
      attribute :payment_status
    end

    class ProductRow < Domino
      selector ".product-row"

      attribute :seller
      attribute :name
      attribute :pricing
      attribute :stock
    end
  end

  class UpcomingDelivery < Domino
    selector ".upcoming-delivery"

    attribute :upcoming_delivery_date
    attribute :location_name
    attribute :location
  end
end
