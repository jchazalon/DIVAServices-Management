class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'Job1'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        p response = DivaServicesApi::Algorithm.validate(algorithm.to_schema)
        if response.success?
          PublishAlgorithmJob.perform_later(algorithm.id)
        else
          algorithm.set_status(:validation_error, "Validation Error\nMessage: #{response['message']}")
        end
        rescue Errno::ECONNREFUSED => e
          algorithm.set_status(:connection_error, 'Connection error during publication, please try again.')
        end
      else
        algorithm.set_status(:error, 'Unknown error during publication, please try again.')
    end
  end
end
