# frozen_string_literal: true

# 顧客訂單資料
class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items
  has_many :products, through: :order_items
  has_many :order_discounts

  before_save :init_order_total
  after_save :update_order_total

  private

  def init_order_total
    self.total = Calculator.new(self).total
  end

  def update_order_total
    self.total = Calculator.new(self).calculate
  end
end
