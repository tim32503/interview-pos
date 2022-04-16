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

      expect(order.total).to(eq(89))
    end

    it '購買豆漿 6 件，冰淇淋 3 件，總計 267 元' do
      order = user.orders.new

      order.order_items.new(product_id: soy_milk.id, quantity: 6).save!
      order.order_items.new(product_id: ice_cream.id, quantity: 3).save!
      order.save!

      expect(order.total).to(eq(267))
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

        expect(order.total).to(eq(850))
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

        expect(order.total).to(eq((subtotal * 0.85).to_i))
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

        expect(order.total).to(eq((@product1.price * 4 - 100).to_i))
      end

      it '購買一號商品 2 件，二號商品 10 件' do
        order = user.orders.new

        order.order_items.new(product_id: @product1.id, quantity: 2).save!
        order.order_items.new(product_id: @product2.id, quantity: 10).save!
        order.save!

        expect(order.total).to(eq((@product1.price * 2 - 50 + @product2.price * 10 - 200).to_i))
      end
    end
  end
end
