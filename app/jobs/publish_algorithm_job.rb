class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'PublishAlgorithmJob'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      p response = DivaServiceApi.publish_algorithm(algorithm)
      if response.success?
        algorithm.update_attribute(:creation_status, :building)
      else
        algorithm.update_attribute(:creation_status, :error)
      end
    end
  end
end
