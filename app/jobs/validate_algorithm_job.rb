class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      #TODO Validate algorithm
      algorithm.update_attribute(:creation_status, :validated)
      PublishAlgorithmJob.perform_later(algorithm.id)
    end
  end
end
