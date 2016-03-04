class CreateInputParameter < ActiveRecord::Migration
  def change
    create_table :input_parameters do |t|
      t.string :input_type
      t.references :algorithm, index: true

      t.timestamps null: false
    end
  end
end
