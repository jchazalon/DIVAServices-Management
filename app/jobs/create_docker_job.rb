class CreateDockerJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    # Do something later
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      p "Start creating docker"


      # Create Dockerfile
      p "Create dockerfile"
      File.open(File.join('tmp/', 'Dockerfile'), 'w+') do |file|
        file.write dockerfile(algorithm)
      end

      # Create Image
      p "Create image"
      image = Docker::Image.build_from_dir('tmp/')
      p image

    end
  end

  def dockerfile(algorithm)
    "FROM #{algorithm.language}\n" +
    "MAINTAINER diva@unifr.ch\n" +
    "RUN apt-get update\n" +
		"COPY /public/uploads/algorithm/zip_file/#{algorithm.id} /data/algorithm/"
  end
end
