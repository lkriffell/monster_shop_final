class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  def subtotal
    quantity * price
  end

  def fulfill
    update(fulfilled: true)
    item.update(inventory: item.inventory - quantity)
  end

  def fulfillable?
    item.inventory >= quantity
  end

  def current_discount(merchant)
    current_discount = nil
    merchant.discounts.order(:min_quantity).reverse.each do |discount|
      if quantity >= discount.min_quantity
        current_discount = discount.percent_off
        break
      end
    end
    current_discount
  end
end
