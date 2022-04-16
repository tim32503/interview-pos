# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Calculator) do
  let!(:soy_milk) { Product.create(name: '豆漿', price: 20) }
  let!(:ice_cream) { Product.create(name: '冰淇淋', price: 49) }
  let!(:user) { FactoryBot.create(:user) }

  describe '無折扣' do
    it '購買豆漿 2 件，冰淇淋 1 件，總計 89 元' do
      order = user.orders.new

      item = order.order_items.new
      item.product_id = soy_milk.id
      item.quantity = 2
      item.save!

      item = order.order_items.new
      item.product_id = ice_cream.id
      item.quantity = 1
      item.save!

      order.save!

      expect(order.total).to(eq(89))
    end

    it '購買豆漿 6 件，冰淇淋 3 件，總計 267 元' do
      order = user.orders.new

      item = order.order_items.new
      item.product_id = soy_milk.id
      item.quantity = 6
      item.save!

      item = order.order_items.new
      item.product_id = ice_cream.id
      item.quantity = 3
      item.save!

      order.save!

      expect(order.total).to(eq(267))
    end
  end

  describe '滿額折扣' do
    xit '訂單滿 X 元折 Z %' do
    end
  end
end
