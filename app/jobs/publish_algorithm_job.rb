class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'Job2'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        algorithm.set_status(:creating, 'Algorithm is currently deploying. This may take several minutes. Grab a coffee.')
        p response = DivaServiceApi.publish_algorithm(algorithm)
        if response.success?
          algorithm.update_attribute(:diva_id, response['identifier'])
          response = DivaServiceApi.status(algorithm.diva_id)
          if !response.empty? && response['statusCode'] != Algorithm.statuses[algorithm.status]
            algorithm.set_status(response['statusCode'], response['statusMessage'])
          end
        else
          algorithm.set_status(:error, "Unknown error during publication, please try again.\n#{response}")
        end
      rescue Errno::ECONNREFUSED => e
        algorithm.set_status(:connection_error, 'Connection error during publication, please try again.')
      end
    else
      algorithm.set_status(:error, 'Unknown error during publication, please try again.')
    end
  end
end
