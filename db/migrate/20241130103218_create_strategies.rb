class CreateStrategies < ActiveRecord::Migration[8.0]
  def change
    create_table :strategies do |t|
      t.string :name
      t.string :market_type
      t.json :parameters

      t.timestamps
    end
  end
end
