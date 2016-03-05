class CreateAlgorithm < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.references :user, index: true
      t.integer :creation_status

      t.string :name
      t.string :namespace
      t.text :description

      t.string :output

      t.timestamps null: false
    end
  end
end
