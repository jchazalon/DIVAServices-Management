class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    p 'Job2'
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        if algorithm.already_published?
          update(algorithm)
        else
          publish(algorithm)
        end
      rescue Errno::ECONNREFUSED => e
        algorithm.set_status(:connection_error, 'Connection error, please try again.')
      end
    else
      algorithm.set_status(:error, 'Algorithm not found, does it still exist?')
    end
  end

  def publish(algorithm)
    diva_algorithm = DivaServicesApi::Algorithm.publish(algorithm.to_schema)
    if diva_algorithm
      algorithm.update_attribute(:diva_id, diva_algorithm.id)
      algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
    else
      algorithm.set_status(:error, "Unknown error during publication, please try again.\n#{diva_algorithm}")
    end
  end

  def update(algorithm)
    old_diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.diva_id)
    diva_algorithm = old_diva_algorithm.update(algorithm.diva_id, algorithm.to_schema)
    if diva_algorithm
      algorithm.update_attribute(:diva_id, diva_algorithm.id)
      algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
    else
      algorithm.set_status(:error, "Unknown error during update, please try again.\n#{diva_algorithm}")
    end
  end
end
