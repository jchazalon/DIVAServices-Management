class CreateAlgorithm < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.references :user, index: true
      t.integer :version, default: 0
      t.integer :status, default: 0
      t.string :status_message

      t.string :diva_id, default: nil

      t.belongs_to :next, default: nil

      t.string :secure_id

      t.timestamps null: false
    end
  end
end
