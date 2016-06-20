##
# ActiveJob used to publicate/update _algorithms_ on the DIVAServices.
class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  ##
  # Main method that is launched with job instance. Published/Updates the given algorithm
  def perform(algorithm_id)
    p 'Publication/Update Job started' if Rails.env.development?
    algorithm = Algorithm.find(algorithm_id)
    if algorithm
      begin
        if algorithm.already_published?
          update(algorithm)
        else
          publish(algorithm)
        end
      rescue Errno::ECONNREFUSED => error
        algorithm.set_status(:connection_error, 'Connection error, please try again.')
      end
    end
  end

  #TODO fix duplicated code below

  ##
  # Publishes the given _algorithm_ to the DIVAServices
  def publish(algorithm)
    begin
      diva_algorithm = DivaServicesApi::Algorithm.publish(algorithm.to_schema)
      if diva_algorithm
        algorithm.update_attribute(:diva_id, diva_algorithm.id)
        algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
      else
        algorithm.set_status(:error, "Error during publication, please try again.\n#{diva_algorithm}")
      end
    rescue Exceptions::DivaServicesError => error
      algorithm.set_status(:error, error.message)
    end
  end

  ##
  # Updates the given _algorithm_ on the DIVAServices
  def update(algorithm)
    begin
      old_diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.diva_id)
      diva_algorithm = old_diva_algorithm.update(algorithm.diva_id, algorithm.to_schema)
      if diva_algorithm
        algorithm.update_attribute(:diva_id, diva_algorithm.id)
        algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
      else
        algorithm.set_status(:error, "Error during update, please try again.\n#{diva_algorithm}")
      end
    rescue Exceptions::DivaServicesError => error
      algorithm.set_status(:error, error.message)
    end
  end
end
