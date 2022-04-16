# frozen_string_literal: true

# 顧客訂單資料
class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items
  has_many :products, through: :order_items

  before_save :calculate_order_total

  private

  def calculate_order_total
    self.total = Calculator.new(self).calculate
  end
end
