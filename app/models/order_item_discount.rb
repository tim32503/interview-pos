class OrderItemDiscount < ApplicationRecord
  belongs_to :order_item
  belongs_to :promotion
end
