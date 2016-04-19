class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      p 'Calling DIVAService at /validate/create'
      p DivaServiceApi.validate_algorithm(algorithm)
      #TODO What happens if it is no valid?

      p 'Update status'
      algorithm.update_attribute(:creation_status, :building)

      PublishAlgorithmJob.perform_later(algorithm.id)
    else
      p "Algorithm ##{algorithm_id} not found!"
    end
  end
end
