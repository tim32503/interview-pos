class CreateOrderItemDiscounts < ActiveRecord::Migration[6.1]
  def change
    create_table :order_item_discounts do |t|
      t.references :order_item, null: false, foreign_key: true
      t.references :promotion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
