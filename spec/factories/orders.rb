# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    total { 1 }
    user factory: :user
  end
end
