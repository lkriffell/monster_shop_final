class Discount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :percent_off, :min_quantity, :merchant_id
end
