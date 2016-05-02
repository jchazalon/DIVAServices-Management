class CreateAlgorithm < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.references :user, index: true
      t.integer :version, default: 1
      t.integer :status, default: 0
      t.string :status_message

      t.string :name
      t.text :description

      t.string :output

      t.string :language
      t.string :environment
      t.string :executable_path

      t.string :diva_id, default: nil

      t.belongs_to :next, default: nil

      t.timestamps null: false
    end
  end
end
