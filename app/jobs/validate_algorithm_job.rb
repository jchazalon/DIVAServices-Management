class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'ValidateAlgorithmJob'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      p response = DivaServiceApi.validate_algorithm(algorithm)
      if response.success?
        algorithm.update_attribute(:creation_status, :building)
        PublishAlgorithmJob.perform_later(algorithm.id)
      else
        algorithm.update_attribute(:creation_status, :error)
      end
    end
  end
end
