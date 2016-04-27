class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'PublishAlgorithmJob'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      p response = DivaServiceApi.publish_algorithm(algorithm)
      #TODO only care about errors or first response?
      # if response.success?
      #   algorithm.update_attribute(:status, :creating)
      # else
      #   algorithm.update_attribute(:status, :error)
      # end
    end
  end
end
