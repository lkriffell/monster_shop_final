class Order < ApplicationRecord
  has_many :order_items
  has_many :items, through: :order_items
  belongs_to :user

  enum status: ['pending', 'packaged', 'shipped', 'cancelled']

  def grand_total
    apply_discount
    order_items.sum('price * quantity')
  end

  def apply_discount
    discounts = discounts_applicable
    order_items.each do |order_item|
      merchant = order_item.item.merchant
      if discounts.include?(merchant.id) && order_item.item.price == order_item.price  
        order_item.update(price: (order_item.price - (order_item.price * discounts[merchant.id])))
      end
    end
  end

  def discounts_applicable
    discounts = {}
    order_items.each do |order_item|
      if order_item.current_discount(order_item.item.merchant)
        discounts[order_item.item.merchant.id] = order_item.current_discount(order_item.item.merchant)
      end
    end
    discounts
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
end
