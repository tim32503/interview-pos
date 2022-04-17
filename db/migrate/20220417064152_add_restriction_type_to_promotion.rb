# frozen_string_literal: true

# Promotion 新增欄位 - 優惠限制類別 & 優惠限制數值
class AddRestrictionTypeToPromotion < ActiveRecord::Migration[6.1]
  def change
    add_column(:promotions, :restriction_type_id, :integer)
    add_column(:promotions, :restriction_value, :float)
  end
end
