# frozen_string_literal: true

class OrderDiscount < ApplicationRecord
  belongs_to :order
  belongs_to :promotion
end
