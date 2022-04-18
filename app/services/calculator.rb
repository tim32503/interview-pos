# frozen_string_literal: true

# 結帳金額計算機
class Calculator
  attr_accessor :original_total, :discount_total, :amount_payable

  def initialize(order)
    @order = order
    @original_total = init_total
    @discount_total = find_discount_total
    @amount_payable = 0
  end

  def calculate
    find_order_promotion
    find_product_promotion
    find_free_product

    @amount_payable = @original_total - @discount_total

    @amount_payable
  end

  private

  def init_total
    @order.order_items.map { |item| item.product.price * item.quantity }.sum
  end

  def find_discount_total
    @order.order_discounts.sum(:amount) + @order.order_items.map { |item| item.order_item_discounts.sum(:amount) }.sum
  end

  def find_order_promotion
    # 找出「訂單折扣、滿額折」的優惠活動
    promotion =
      Promotion.find_by(
        discount_object: 'Order',
        discount_type_id: [1, 2],
        threshold_type_id: 2,
        threshold_value: Float::INFINITY..@original_total
      )

    return unless promotion.present?

    if promotion.restriction_type_id.present?
      discount_count =
        case promotion.restriction_type
        when 'usable_count_limit'
          OrderDiscount.where(promotion_id: promotion.id).size
        when 'amount_limit_per_user'
          OrderDiscount.includes(order: :user)
                       .where(promotion_id: promotion.id, orders: { user_id: @order.user.id })
                       .sum(:amount)
        end

      return if discount_count >= promotion.restriction_value

      quota = promotion.restriction_value - discount_count
    end

    discount_subtotal =
      case promotion.discount_type
      when 'amount'
        promotion.discount_value.to_i * (@original_total / promotion.threshold_value).to_i
      when 'percentage'
        (@original_total * (100 - promotion.discount_value) / 100).to_i
      end

    if quota.present?
      discount_subtotal = (quota >= discount_subtotal ? discount_subtotal : quota).to_i
    end

    @discount_total += discount_subtotal

    @order.order_discounts.new(promotion_id: promotion.id, amount: @discount_total).save!
  end

  def find_product_promotion
    @order.order_items.find_each do |item|
      promotion =
        Promotion.find_by(
          discount_object: 'Product',
          discount_type_id: 1,
          object_id: item.product.id,
          threshold_type_id: 1
        )

      if promotion.present? && item.quantity >= promotion.threshold_value
        amount = (promotion.discount_value * (item.quantity / promotion.threshold_value)).to_i
        @discount_total += amount

        item.order_item_discounts.new(promotion_id: promotion.id, amount: amount).save!
      end
    end
  end

  def find_free_product
    promotion =
      Promotion.find_by(
        discount_object: 'Order',
        discount_type_id: 3,
        threshold_type_id: 2,
        threshold_value: Float::INFINITY..@original_total
      )

    return unless promotion.present?

    free_product = Product.find(promotion.object_id)

    @order.order_items.new(product_id: free_product.id, quantity: 1).save!
    @discount_total += free_product.price
    @order.order_discounts.new(promotion_id: promotion.id, amount: free_product.price).save!
  end
end
