class CreateAlgorithmInfo < ActiveRecord::Migration
  def change
    create_table :algorithm_infos do |t|
      t.references :algorithm, index: true
      t.json :payload
    end
  end
end
