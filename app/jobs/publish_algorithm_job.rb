class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    algorithm.update_attribute(:creation_status, :published) if algorithm
  end
end
