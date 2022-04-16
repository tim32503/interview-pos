# frozen_string_literal: true

FactoryBot.define do
  factory :promotion do
    factory :one_hundred_off_for_one_thousand
    name { '無折扣限制，滿 1000 元折 100 元' }
    discount_object { 'Order' }
    discount_type_id { 1 }
    object_id { nil }
    discount_value { 100 }
    threshold_value { 1000 }
    threshold_type_id { 2 }
  end
end
