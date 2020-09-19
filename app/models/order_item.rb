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

  def apply_discount
    if item.discount && quantity >= item.discount.quantity_required
      total_off = self.discount * self.subtotal
      subtotal = self.subtotal - total_off
    else
      self.subtotal
    end
  end
end
