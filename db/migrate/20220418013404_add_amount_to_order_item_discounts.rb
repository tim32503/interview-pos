# frozen_string_literal: true

# OrderItemDiscounts 新增 amount 金額欄位
class AddAmountToOrderItemDiscounts < ActiveRecord::Migration[6.1]
  def change
    add_column(:order_item_discounts, :amount, :float, default: 0)
  end
end
