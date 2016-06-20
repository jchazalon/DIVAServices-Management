##
# ActiveJob used to validate _algorithms_ on the DIVAServices.
class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  ##
  # Main method that is launched with job instance. Validates the given algorithm.
  def perform(algorithm_id)
    p 'Validation Job started' if Rails.env.development?
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        response = DivaServicesApi::Algorithm.validate(algorithm.to_schema)
        if response.success?
          PublishAlgorithmJob.perform_later(algorithm.id)
        else
          algorithm.set_status(:validation_error, "Validation Error\nMessage: #{response['message']}")
        end
      rescue Errno::ECONNREFUSED => error
        algorithm.set_status(:connection_error, 'Connection error during publication, please try again.')
      end
    end
  end
end
