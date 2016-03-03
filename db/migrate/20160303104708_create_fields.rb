class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :type, index: true
      t.references :field, index: true
      t.references :input_parameter, index: true
      t.json :payload
    end
  end
end
