class CreateAlgorithmInfo < ActiveRecord::Migration
  def change
    create_table :algorithm_infos do |t|
      t.references :algorithm, index: true
      t.json :payload

      t.timestamps null: false
    end
  end
end
