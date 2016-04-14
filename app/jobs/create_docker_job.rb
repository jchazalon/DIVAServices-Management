class CreateDockerJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm

      # Create/Clean docker folder
      directory = "#{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/"
      FileUtils.rm_rf(directory) if File.exists?(directory)
      Dir.mkdir(directory)

      p 'Create Dockerfile'
      create_dockerfile(directory, algorithm)
      #TODO select and provide correct base images
      #TODO Add entrypoint/cmd
      #TODO add script to run algorithm

      p 'Extract algorithm'
      extract_algorithm(directory, algorithm)

      p 'Create tar'
      `cd #{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/ && tar -zcvf docker.tar * && cd #{Rails.root}`

      p 'Build image'
      build_image(directory, algorithm)
      #TODO Check for errors

      p 'Update status'
      algorithm.update_attribute(:creation_status, :built)
      #XXX PublishAlgorithmJob.perform_later(algorithm.id)
    else
      p 'Algorithm not found!'
    end
  end

  def build_image(directory, algorithm)
    p image = Docker::Image.build_from_tar(File.open(File.join(directory, 'docker.tar'), 'r'), { t: algorithm.name.downcase.tr(' ', '_') })
    algorithm.image = image.id
  end

  def extract_algorithm(directory, algorithm)
    Zip::File.open("#{directory}../algorithm.zip") do |zipfile|
      zipfile.each do |file|
        file_path = File.join(directory, file.name)
        FileUtils.mkdir_p(File.dirname(file_path))
        zipfile.extract(file, file_path) unless File.exist?(file_path)
      end
    end
  end

  def create_dockerfile(directory, algorithm)
    File.open(File.join(directory, 'Dockerfile'), 'w+') do |file|
      file.write dockerfile
    end
  end

  def dockerfile
    "FROM ubuntu\n" +
    "MAINTAINER diva@unifr.ch\n" +
    "RUN apt-get update\n" +
    "COPY . /data/algorithm/"
  end
end
