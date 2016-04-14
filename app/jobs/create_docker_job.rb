class CreateDockerJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm

      p 'Create Dockerfile'
      create_dockerfile(algorithm)
      #TODO select and provide correct base images
      #TODO Add entrypoint/cmd
      #TODO add script to run algorithm

      p 'Extract algorithm'
      extract_algorithm(algorithm)
      #TODO name zips all the same
      #TODO what if its not a zip?

      p 'Create tar'
      `cd #{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/ && tar -zcvf docker.tar * && cd #{Rails.root}`

      p 'Build image'
      build_image(algorithm)
      #TODO Check for errors

      p 'Update status'
      algorithm.update_attribute(:creation_status, :built)
      PublishAlgorithmJob.perform_later(algorithm.id)
    else
      p 'Algorithm not found!'
    end
  end

  def build_image(algorithm)
    image = Docker::Image.build_from_tar(File.open(File.join("#{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/", 'docker.tar'), 'r'))
    algorithm.image = image.id
  end

  def extract_algorithm(algorithm)
    Zip::File.open("#{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/dummy.zip") do |zipfile|
      zipfile.each do |file|
        file_path = File.join("#{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/", file.name)
        FileUtils.mkdir_p(File.dirname(file_path))
        zipfile.extract(file, file_path) unless File.exist?(file_path)
      end
    end
  end

  def create_dockerfile(algorithm)
    directory = "#{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/"
    Dir.mkdir(directory) unless File.exists?(directory)
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
