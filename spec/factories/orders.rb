# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    total
    user factory: :user
  end
end
