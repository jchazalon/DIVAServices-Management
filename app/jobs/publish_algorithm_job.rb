class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      response = DivaServiceApi.publish_algorithm(algorithm)
      if response.success?
        algorithm.update_attribute(:creation_status, :building)
      else
        algorithm.update_attribute(:creation_status, :error)
      end
    end
  end
end
