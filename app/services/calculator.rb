# frozen_string_literal: true

# 結帳金額計算機
class Calculator
  attr_accessor :total

  def initialize(order)
    @order = order
    @total = init_total
  end

  def calculate
    handle_discount

    @total - @discount_total
  end

  private

  def init_total
    @order.order_items.map { |item| item.product.price * item.quantity }.sum
  end

  def handle_discount
    @discount_total = 0

    find_usable_order_promotion
    find_usable_product_promotion
  end

  def find_usable_order_promotion
    # 找出「訂單折扣、滿額折」的優惠活動
    promotion =
      Promotion.find_by(discount_object: 'Order', threshold_type_id: 2, threshold_value: Float::INFINITY..@order.total)

    return unless promotion.present?

    @order.order_discounts.new(promotion_id: promotion.id).save!

    @discount_total +=
      case promotion.discount_type
      when 'amount'
        promotion.discount_value
      when 'percentage'
        @order.total * (1 - (promotion.discount_value / 100))
      end
  end

  def find_usable_product_promotion
    @order.order_items.find_each do |item|
      promotion =
        Promotion.find_by(
          discount_object: 'Product',
          discount_type_id: 1,
          object_id: item.product.id,
          threshold_type_id: 1
        )

      if promotion.present? && item.quantity >= promotion.threshold_value
        @discount_total += (promotion.discount_value * (item.quantity / promotion.threshold_value))

        item.order_item_discounts.new(promotion_id: promotion.id).save!
      end
    end
  end
end
