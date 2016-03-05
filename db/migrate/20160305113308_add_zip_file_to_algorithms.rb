class AddZipFileToAlgorithms < ActiveRecord::Migration
  def change
    add_column :algorithms, :zip_file, :string
  end
end
