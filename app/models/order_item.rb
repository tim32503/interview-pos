# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  has_many :order_item_discounts
  has_many :promotions, through: :order_item_discounts
end
