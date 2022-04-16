# frozen_string_literal: true

# 顧客訂單資料
class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items
  has_many :products, through: :order_items
  has_many :order_discount

  before_save :calculate_order_total
  after_save :find_usable_order_promotion

  private

  def calculate_order_total
    self.total = Calculator.new(self).calculate
  end

  def find_usable_order_promotion
    # 找出「訂單折扣、滿額折」的優惠活動
    promotion =
      Promotion.find_by(discount_object: 'Order', threshold_type_id: 2, threshold_value: Float::INFINITY..total)

    return unless promotion.present?

    order_discount.create!(promotion_id: promotion.id)

    discount_total =
      case promotion.discount_type
      when 'amount'
        promotion.discount_value
      when 'percentage'
        total * (1 - (promotion.discount_value / 100))
      end

    self.total -= discount_total
  end
end
