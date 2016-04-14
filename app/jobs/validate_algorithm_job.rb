class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm

      p 'Calling /validate/create'
      p DivaServiceApi.validate_algorithm(algorithm)

      p 'Update status to validated'
      algorithm.update_attribute(:creation_status, :validated)

      p 'Startin publication'
      CreateDockerJob.perform_later(algorithm.id)
    else
      p 'Algorithm not found!'
    end
  end
end
