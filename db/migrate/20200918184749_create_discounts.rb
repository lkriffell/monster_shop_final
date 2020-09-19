class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :discounts do |t|
      t.float :discount
      t.integer :quantity_required
      t.references :item, foreign_key: true
      t.references :merchant, foreign_key: true
    end
  end
end
