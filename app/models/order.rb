class Order < ApplicationRecord
  has_many :order_items
  has_many :items, through: :order_items
  belongs_to :user

  enum status: ['pending', 'packaged', 'shipped', 'cancelled']

  def grand_total
    order_items.sum('price * quantity')
  end

  def grand_total_after_discount
    discounts = []
    total_undiscounted = 0.0
    grand_total = 0.0
    order_items.each do |order_item|
      item = order_item.item
      if item.discount && order_item.quantity >= item.discount.quantity_required
        grand_total += (item.price * order_item.quantity)
        discounts << item.discount.discount
      elsif
        total_undiscounted += (item.price * order_item.quantity)
      end
    end
    if discounts != []
      set_discounts(order_items, discounts.max)
      grand_total -= (grand_total * discounts.max)
    end
    grand_total += total_undiscounted
  end

  def count_of_items
    order_items.sum(:quantity)
  end

  def cancel
    update(status: 'cancelled')
    order_items.each do |order_item|
      order_item.update(fulfilled: false)
      order_item.item.update(inventory: order_item.item.inventory + order_item.quantity)
    end
  end

  def merchant_subtotal(merchant_id)
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .where("items.merchant_id = #{merchant_id}")
      .sum('order_items.price * order_items.quantity')
  end

  def merchant_quantity(merchant_id)
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .where("items.merchant_id = #{merchant_id}")
      .sum('order_items.quantity')
  end

  def is_packaged?
    update(status: 1) if order_items.distinct.pluck(:fulfilled) == [true]
  end

  def self.by_status
    order(:status)
  end

  def set_discounts(order_items, discount)
    order_items.each do |order_item|
      item = order_item.item
      if item.discount && order_item.quantity >= item.discount.quantity_required
        order_item.update(discount: discount)
      end
    end
  end
end
