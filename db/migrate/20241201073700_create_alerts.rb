class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.string :ticker
      t.decimal :close, precision: 15, scale: 2
      t.datetime :time
      t.integer :volume
      t.string :action
      t.string :market
      t.string :exchange
      t.string :error_message
      t.string :current_position
      t.string :previous_position
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
