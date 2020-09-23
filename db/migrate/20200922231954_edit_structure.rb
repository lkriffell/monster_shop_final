class EditStructure < ActiveRecord::Migration[5.2]
  def change
    create_table "items", force: :cascade do |t|
      t.string "name"
      t.string "description"
      t.float "price"
      t.integer "inventory"
      t.string "image"
      t.boolean "active", default: true
      t.bigint "merchant_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["merchant_id"], name: "index_items_on_merchant_id"
    end

    create_table "order_items", force: :cascade do |t|
      t.bigint "item_id"
      t.bigint "order_id"
      t.float "price"
      t.integer "quantity"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "fulfilled", default: false
      t.index ["item_id"], name: "index_order_items_on_item_id"
      t.index ["order_id"], name: "index_order_items_on_order_id"
    end
  end
end
