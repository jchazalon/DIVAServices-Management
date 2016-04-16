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

      p 'Create script.sh'
      create_script(directory, algorithm)
      #TODO add script to run algorithm
      #TODO move script outside of algorithm folder!!!!

      p 'Extract algorithm'
      extract_algorithm(directory, algorithm)

      p 'Create tar'
      `cd #{Rails.root}/public/uploads/algorithm/zip_file/#{algorithm.id}/docker/ && tar -zcvf docker.tar * && cd #{Rails.root}`

      p 'Build image'
      build_image(directory, algorithm)
      #TODO Check for errors

      p 'Done'
      #XXX PublishAlgorithmJob.perform_later(algorithm.id)
    else
      p 'Algorithm not found!'
    end
  end

  def build_image(directory, algorithm)
    begin
      image = Docker::Image.build_from_tar(File.open(File.join(directory, 'docker.tar'), 'r'), { t: algorithm.name.downcase.tr(' ', '_') })
      algorithm.image = image.id
      algorithm.update_attribute(:creation_status, :built)
    rescue => e
      Rails.logger.error { "ERROR while building: #{e.message} #{e.backtrace.join("\n")}" }
      algorithm.update_attribute(:creation_status, :error)
    end
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

  def create_script(directory, algorithm)
    File.open(File.join(directory, 'script.sh'), 'w+') do |file|
      file.write script(algorithm)
    end
  end

  def create_dockerfile(directory, algorithm)
    File.open(File.join(directory, 'Dockerfile'), 'w+') do |file|
      file.write dockerfile(algorithm)
    end
  end

  def script(algorithm)
    "#!/bin/sh\n" +
    "wget -O /data/dummy_image.png http://dummyimage.com/600x400/adadad/ffffff\n" +
    "/data/algorithm/#{algorithm.executable_path} dummy_image.png ."
  end

  def dockerfile(algorithm)
    "FROM java:openjdk-9\n" +
    "MAINTAINER diva@unifr.ch\n" +
    "RUN apt-get update\n" +
    "RUN apt-get install wget\n" +
    "COPY . /data/algorithm/\n" +
    "ENTRYPOINT /data/algorithm/script.sh"
  end
end
