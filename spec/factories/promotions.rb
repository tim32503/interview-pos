# frozen_string_literal: true

FactoryBot.define do
  factory :promotion do
    factory :fifteen_percent_off_over_one_thousand do
      name { '無折扣限制，滿 1000 元 85 折' }
      discount_object { 'Order' }
      discount_type_id { 2 }
      object_id { nil }
      discount_value { 85 }
      threshold_value { 1000 }
      threshold_type_id { 2 }
    end

    factory :specific_items_discount do
      name { '特定商品滿 2 件 折 50 元' }
      discount_object { 'Product' }
      discount_type_id { 1 }
      discount_value { 50 }
      threshold_value { 2 }
      threshold_type_id { 1 }
    end
  end
end
