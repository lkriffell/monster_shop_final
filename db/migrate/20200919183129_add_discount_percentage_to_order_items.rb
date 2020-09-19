class AddDiscountPercentageToOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :order_items, :discount, :float
  end
end
