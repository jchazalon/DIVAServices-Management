class CreateOutputParameter < ActiveRecord::Migration
  def change
    create_table :output_parameters do |t|
      t.string :output_type
      t.integer :position
      t.string :name
      t.string :description
      t.references :algorithm, index: true

      t.timestamps null: false
    end
  end
end
