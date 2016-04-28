class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        response = DivaServiceApi.publish_algorithm(algorithm)
        if response.success?
          algorithm.update_attribute(:diva_id, response['identifier'])
          algorithm.update_attribute(:status, :creating)
          algorithm.update_attribute(:status_message, 'Algorithm is currently deploying. This may take several minutes. Grab a coffee.')
        else
          algorithm.update_attribute(:status, :error)
          algorithm.update_attribute(:status_message, 'Unknown error during publication, please try again.')
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
