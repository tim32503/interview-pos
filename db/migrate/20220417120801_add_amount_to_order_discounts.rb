# frozen_string_literal: true

# OrderDiscount 新增 amount 金額欄位
class AddAmountToOrderDiscounts < ActiveRecord::Migration[6.1]
  def change
    add_column(:order_discounts, :amount, :float, default: 0)
  end
end
