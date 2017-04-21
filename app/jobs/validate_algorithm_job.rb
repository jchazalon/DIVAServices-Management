##
# ActiveJob used to validate _algorithms_ on the DIVAServices.
class ValidateAlgorithmJob < ActiveJob::Base
  queue_as :default

    rescue_from(StandardError) do |exception|
      Rails.logger.error "[#{self.class.name}] Hey, something was wrong with you job #{exception.to_s}"       
    end

  ##
  # Main method that is launched with job instance. Validates the given algorithm.
  def perform(algorithm_id)
    p 'Validation Job started' if Rails.env.development?
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        if DivaServicesApi::Algorithm.validate(algorithm.to_schema)
          PublishAlgorithmJob.perform_later(algorithm.id)
        else
          algorithm.set_status(:validation_error, "Validation was not sucessful, please review the following message:\n#{DivaServicesApi::Algorithm.validation_message(algorithm.to_schema)}")
        end
      rescue Errno::ECONNREFUSED => error
        algorithm.set_status(:connection_error, 'The DIVAServices cannot be reached at the moment. Please try again later.')
      end
    end
  end
end
