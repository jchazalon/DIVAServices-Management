class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :type, index: true
      t.references :fieldable, polymorphic: true, index: true
      t.json :payload

      t.timestamps null: false
    end
  end
end
