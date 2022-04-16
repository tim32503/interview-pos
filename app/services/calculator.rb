# frozen_string_literal: true

# 結帳金額計算機
class Calculator
  def initialize(order)
    @order = order
    @order_items = order.order_items
  end

  def calculate
    handle_discount

    init_total
  end

  private

  def init_total
    @order_items.map { |item| item.product.price * item.quantity }.sum
  end

  def handle_discount; end
end
