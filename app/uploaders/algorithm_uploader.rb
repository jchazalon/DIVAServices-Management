# encoding: utf-8
##
# Responsible for the upload of algorithm zip files. Bases on a gem called {carrierwave}[https://github.com/carrierwaveuploader/carrierwave].
class AlgorithmUploader < CarrierWave::Uploader::Base

  storage :file

  ##
  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  ##
  # White list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(zip)
  end

  ##
  # Override the filename of the uploaded files
  def filename
    "algorithm.#{file.extension}" if original_filename
  end

  ##
  # 'Deep copy' of a file
  def self.copy_file(src_id, dst_id)
    FileUtils.mkdir_p("#{Rails.root}/public/uploads/algorithm/zip_file/#{dst_id}/")
    FileUtils.cp(File.join(Rails.root, "public/uploads/algorithm/zip_file/#{src_id}/algorithm.zip"), "#{Rails.root}/public/uploads/algorithm/zip_file/#{dst_id}/")
  end
end
