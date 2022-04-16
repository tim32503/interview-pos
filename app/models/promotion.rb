# frozen_string_literal: true

class Promotion < ApplicationRecord
  DISOUNT_OBJECT = %w[Order Product].freeze
  DISCOUNT_TYPE = [
    { id: 1, code: 'amount', name: '金額' },
    { id: 2, code: 'percentage', name: '百分比' }
  ].freeze
  THRESHOLD_TYPE = [
    { id: 1, code: 'piece', name: '滿件' },
    { id: 2, code: 'amount', name: '滿額' },
  ].freeze
end
