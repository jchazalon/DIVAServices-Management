class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        response = DivaServiceApi.validate_algorithm(algorithm)
        if response.success?
          PublishAlgorithmJob.perform_later(algorithm.id)
        else
          algorithm.update_attribute(:status, :validation_error)
          algorithm.update_attribute(:status_message, "Validation Error\nMessage: #{response['message']}")
        end
        rescue Errno::ECONNREFUSED => e
          algorithm.update_attribute(:status, :connection_error)
          algorithm.update_attribute(:status_message, 'Connection error during publication, please try again.')
        end
      else
        algorithm.update_attribute(:status, :error)
        algorithm.update_attribute(:status_message, 'Unknown error during publication, please try again.')
    end
  end
end
