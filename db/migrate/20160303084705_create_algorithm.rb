class CreateAlgorithm < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.references :user, index: true
      t.integer :status, default: 0
      t.string :status_message

      t.string :name
      t.text :description

      t.string :output

      t.string :language
      t.string :environment
      t.string :executable_path

      t.timestamps null: false
    end
  end
end
