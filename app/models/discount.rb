class Discount < ApplicationRecord
  belongs_to :merchant
  belongs_to :item

  validates_presence_of :discount, :quantity_required, :item_id, :merchant_id
end
