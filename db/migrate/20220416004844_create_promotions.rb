# frozen_string_literal: true

# 新增 Promotion 優惠資料表
class CreatePromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :discount_object
      t.integer :discount_type_id
      t.integer :object_id
      t.float :discount_value
      t.float :threshold_value
      t.integer :threshold_type_id

      t.timestamps
    end
  end
end
