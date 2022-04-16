# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Calculator) do
  let!(:user) { FactoryBot.create(:user) }
  let!(:soy_milk) { Product.create(name: '豆漿', price: 20) }
  let!(:ice_cream) { Product.create(name: '冰淇淋', price: 49) }
  let!(:fifteen_percent_off_over_one_thousand) { FactoryBot.create(:fifteen_percent_off_over_one_thousand) }

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

  describe '滿額折扣' do
    context '訂單滿 1000 元 85 折' do
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
end
