class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      p 'Calling DIVAService at /management/algorithm'
      p DivaServiceApi.publish_algorithm(algorithm)
      #TODO What happens if there is a error?

      p 'Update status to'
      algorithm.update_attribute(:creation_status, :building)
    else
      p "Algorithm ##{algorithm_id} not found!"
    end
  end
end
