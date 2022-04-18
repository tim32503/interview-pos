# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Calculator) do
  let!(:user) { FactoryBot.create(:user) }
  let!(:soy_milk) { Product.create(name: '豆漿', price: 20) }
  let!(:ice_cream) { Product.create(name: '冰淇淋', price: 49) }

  describe '無折扣' do
    it '購買豆漿 2 件，冰淇淋 1 件，總計 89 元' do
      order = user.orders.new

      order.order_items.new(product_id: soy_milk.id, quantity: 2).save!
      order.order_items.new(product_id: ice_cream.id, quantity: 1).save!
      order.save!

      result = Calculator.new(order)
      result.calculate

      expect(result.original_total).to(eq(89))
      expect(result.discount_total).to(eq(0))
      expect(order.total).to(eq(result.amount_payable))
    end

    it '購買豆漿 6 件，冰淇淋 3 件，總計 267 元' do
      order = user.orders.new

      order.order_items.new(product_id: soy_milk.id, quantity: 6).save!
      order.order_items.new(product_id: ice_cream.id, quantity: 3).save!
      order.save!

      result = Calculator.new(order)
      result.calculate

      expect(result.original_total).to(eq(267))
      expect(result.discount_total).to(eq(0))
      expect(order.total).to(eq(result.amount_payable))
    end
  end

  describe '訂單滿 X 元折 Z %' do
    context '訂單滿 1000 元 85 折' do
      before(:each) do
        FactoryBot.create(:fifteen_percent_off_over_one_thousand)
      end

      it '購買豆漿 1 件，冰淇淋 20 件，總計 850 元' do
        order = user.orders.new

        order.order_items.new(product_id: soy_milk.id, quantity: 1).save!
        order.order_items.new(product_id: ice_cream.id, quantity: 20).save!
        order.save!

        result = Calculator.new(order)
        result.calculate

        expect(result.original_total).to(eq(1000))
        expect(result.discount_total).to(eq(150))
        expect(order.total).to(eq(result.amount_payable))
      end

      it '總計 X * 0.85 元' do
        order = user.orders.new
        subtotal = 0

        while subtotal < 1000
          product = FactoryBot.create(:product)
          quantity = Faker::Number.number(digits: 1)
          order.order_items.new(product_id: product.id, quantity: quantity).save!
          subtotal += (product.price * quantity)
        end

        order.save!

        result = Calculator.new(order)
        result.calculate

        expect(result.original_total).to(eq(subtotal))
        expect(result.discount_total).to(eq((subtotal * 15 / 100).round))
        expect(order.total).to(eq(result.amount_payable))
      end
    end
  end

  describe '特定商品滿 X 件折 Y 元' do
    context '一號商品滿 2 件折 50 元，二號商品滿 5 件折 100 元' do
      before(:each) do
        @product1 = FactoryBot.create(:product)
        FactoryBot.create(:specific_items_discount, object_id: @product1.id)

        @product2 = FactoryBot.create(:product)
        FactoryBot.create(
          :specific_items_discount,
          object_id: @product2.id,
          threshold_value: 5,
          discount_value: 100,
          name: '特定商品滿 5 件 折 100 元'
        )
      end

      it '購買一號商品 4 件' do
        order = user.orders.new

        order.order_items.new(product_id: @product1.id, quantity: 4).save!
        order.save!

        result = Calculator.new(order)
        result.calculate

        expect(result.original_total).to(eq(@product1.price * 4))
        expect(result.discount_total).to(eq(100))
        expect(order.total).to(eq(result.amount_payable))
      end

      it '購買一號商品 2 件，二號商品 10 件' do
        order = user.orders.new

        order.order_items.new(product_id: @product1.id, quantity: 2).save!
        order.order_items.new(product_id: @product2.id, quantity: 10).save!
        order.save!

        result = Calculator.new(order)
        result.calculate

        expect(result.original_total).to(eq(@product1.price * 2 + @product2.price * 10))
        expect(result.discount_total).to(eq(50 + 200))
        expect(order.total).to(eq(result.amount_payable))
      end
    end
  end

  describe '訂單滿 X 元贈送特定商品 1 件' do
    before(:each) do
      @free_product = FactoryBot.create(:product)
    end

    it '訂單滿 399 元贈送特定商品 1 件' do
      FactoryBot.create(
        :promotion,
        name: '訂單滿 399 元贈送特定商品 1 件',
        discount_object: 'Order',
        discount_type_id: 3,
        object_id: @free_product.id,
        threshold_value: 399,
        threshold_type_id: 2
      )

      order = user.orders.new
      subtotal = 0

      while subtotal < 399
        product = FactoryBot.create(:product)
        quantity = Faker::Number.number(digits: 1)
        order.order_items.new(product_id: product.id, quantity: quantity).save!
        subtotal += (product.price * quantity)
      end

      order.save!

      expect(order.products).to(include(@free_product))
    end
  end

  describe '訂單滿 X 元折 Y 元,此折扣在全站總共只能套用 N 次' do
    before(:each) do
      @promotion = FactoryBot.create(
        :promotion,
        name: '滿 1000 元折 100 元，全站僅限套用 10 次',
        discount_object: 'Order',
        discount_type_id: 1,
        discount_value: 100,
        threshold_type_id: 2,
        threshold_value: 1000,
        restriction_type_id: 1,
        restriction_value: 10
      )
    end

    it '訂單滿 1000 元折 100 元，全站僅限套用 10 次' do
      used_count = 0

      while used_count < @promotion.restriction_value
        order = user.orders.new
        subtotal = 0

        while subtotal < 1000
          product = FactoryBot.create(:product)
          quantity = Faker::Number.number(digits: 1)
          order.order_items.new(product_id: product.id, quantity: quantity).save!
          subtotal += (product.price * quantity)
        end

        order.save!

        used_count = OrderDiscount.where(promotion_id: @promotion.id).size
      end

      expect(used_count).to(eq(@promotion.restriction_value.to_i))
    end
  end

  describe '訂單滿 X 元折 Z %，折扣每人只能總共優惠 N 元' do
    before(:each) do
      @promotion = FactoryBot.create(
        :promotion,
        name: '滿 1000 元 9 折，每人折扣上限 200 元',
        discount_object: 'Order',
        discount_type_id: 2,
        discount_value: 90,
        threshold_type_id: 2,
        threshold_value: 1000,
        restriction_type_id: 2,
        restriction_value: 200
      )
    end

    it '訂單滿 1000 元 9 折，每人折扣上限 200 元' do
      subtotal = 0
      order = user.orders.new

      while subtotal * 0.1 < @promotion.restriction_value
        product = FactoryBot.create(:product)
        quantity = Faker::Number.between(from: 1, to: 9)
        order.order_items.new(product_id: product.id, quantity: quantity).save!
        subtotal += (product.price * quantity)
      end

      order.save!

      discount_amount_total =
        OrderDiscount.includes(order: :user)
                     .where(promotion_id: @promotion.id, orders: { user_id: user.id })
                     .sum(:amount)

      expect(discount_amount_total).to(eq(200))
      expect(order.total).to(eq(subtotal - 200))
    end
  end
end
