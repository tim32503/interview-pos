# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::Food.dish.unique }
    price { Faker::Number.between(from: 100, to: 999) }
  end
end
