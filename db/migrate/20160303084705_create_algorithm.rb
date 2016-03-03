class CreateAlgorithm < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.references :user, index: true
      t.string :name
      t.string :namespace
      t.text :description
    end
  end
end
