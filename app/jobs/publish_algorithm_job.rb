class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'Job2'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        algorithm.set_status(:creating, 'Algorithm is currently deploying. This may take several minutes. Grab a coffee.')

        if diva_algorithm = DivaServicesApi::Algorithm.publish(algorithm.to_schema)
          algorithm.update_attribute(:diva_id, diva_algorithm.id)
          diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.diva_id)
          if diva_algorithm.status_code != Algorithm.statuses[algorithm.status]
            algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
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
