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

  def grand_total_after_discount
    discounts = []
    total_undiscounted = 0.0
    grand_total_after_discount = 0.0
    @contents.each do |item_id, quantity|
      item = Item.find(item_id)
      if item.discount && contents[item.id.to_s] >= item.discount.quantity_required
        grand_total_after_discount += (item.price * quantity)
        discounts << item.discount.discount
      elsif
        total_undiscounted += (item.price * quantity)
      end
    end
    if discounts != []
      grand_total_after_discount -= (grand_total_after_discount * discounts.max)
    end
    grand_total_after_discount += total_undiscounted
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

  def apply_discount(item)
    if item.discount && contents[item.id.to_s] >= item.discount.quantity_required
      total_off = item.discount.discount * subtotal_of(item.id)
      subtotal = subtotal_of(item.id) - total_off
    else
      subtotal_of(item.id)
    end
  end

end
