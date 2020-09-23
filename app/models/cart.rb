class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents || {}
    @contents.default = 0
  end

  def add_item(item_id)
    @contents[item_id] += 1
  end

  def less_item(item_id)
    @contents[item_id] -= 1
  end

  def count
    @contents.values.sum
  end

  def items
    @contents.map do |item_id, _|
      Item.find(item_id)
    end
  end

  def grand_total
    grand_total = 0.0
    @contents.each do |item_id, quantity|
      grand_total += Item.find(item_id).price * quantity
    end
    grand_total
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def subtotal_of(item_id)
    @contents[item_id.to_s] * Item.find(item_id).price
  end

  def limit_reached?(item_id)
    count_of(item_id) == Item.find(item_id).inventory
  end

  def calculate(current_discount, item_id)
    total_off = subtotal_of(item_id) * current_discount
    subtotal_of(item_id) - total_off
  end

  def grand_total_after_discount
    total = 0.0
    merchants_in_cart.each do |merchant|
      merchant.items.where(id: contents.keys).each do |item|
        total += apply_discount(item).to_f
      end
    end
    total
  end

  def apply_discount(item)
    current_discount = current_discount(item.merchant)
    if current_discount
      calculate(current_discount, item.id)
    else
      subtotal_of(item.id)
    end
  end

  def current_discount(merchant)
    current_discount = nil
    merchant_contents = merchant_contents_in_cart(merchant)
    merchant.discounts.order(:min_quantity).reverse.each do |discount|
      if merchant_contents.invert.max[0] >= discount.min_quantity
        current_discount = discount.percent_off
        break
      end
    end
    current_discount
  end

  def merchant_contents_in_cart(merchant)
    merchant_contents = {}
    merchant_items = merchant.items.where(id: contents.keys).pluck(:id)
    contents.each do |item_id, quantity|
      if merchant_items.include?(item_id.to_i)
        merchant_contents[item_id] = quantity
      end
    end
    merchant_contents
  end

  def merchants_in_cart
    contents.map do |item_id, quantity|
      Merchant.find(Item.find(item_id).merchant_id)
    end.uniq
  end
end
