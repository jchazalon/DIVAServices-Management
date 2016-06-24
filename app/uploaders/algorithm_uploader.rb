# encoding: utf-8
##
# Responsible for the upload of algorithm zip files. Bases on a gem called {carrierwave}[https://github.com/carrierwaveuploader/carrierwave].
class AlgorithmUploader < CarrierWave::Uploader::Base

  storage :file

  ##
  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.secure_id}"
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
  def copy_file(dst_id)
    destination_algorithm = Algorithm.find(dst_id)
    destination_path = ::File.expand_path(destination_algorithm.zip_file.store_dir, root)
    source_path = ::File.expand_path(store_dir, root)
    FileUtils.mkdir_p(destination_path)
    FileUtils.cp(File.join(source_path, "/algorithm.zip"), destination_path)
  end
end
