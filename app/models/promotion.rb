# frozen_string_literal: true

# Promotion 優惠組合
class Promotion < ApplicationRecord
  DISOUNT_OBJECT = %w[Order Product Gift].freeze
  DISCOUNT_TYPE = [
    { id: 1, code: 'amount', name: '金額' },
    { id: 2, code: 'percentage', name: '百分比' },
    { id: 3, code: 'free', name: '贈送' }
  ].freeze
  THRESHOLD_TYPE = [
    { id: 1, code: 'piece', name: '滿件' },
    { id: 2, code: 'amount', name: '滿額' }
  ].freeze
  RESTRICTION_TYPE = [
    { id: 1, code: 'usable_count', name: '全站限制使用次數' }
  ].freeze

  has_many :order_discounts
  has_many :orders, through: :order_discounts
  has_many :order_item_discounts
  has_many :order_items, through: :order_item_discounts

  def discount_type
    DISCOUNT_TYPE.filter { |type| type[:id] == discount_type_id }[0][:code]
  end
end
