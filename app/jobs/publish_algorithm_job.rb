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
        algorithm.set_status(:connection_error, 'The DIVAServices cannot be reached at the moment. Please try again later.')
      end
    end
  end

  #TODO fix duplicated code below

  ##
  # Publishes the given _algorithm_ to the DIVAServices
  def publish(algorithm)
    p 'Publising algorithm' if Rails.env.development?
    diva_algorithm = DivaServicesApi::Algorithm.publish(algorithm.to_schema)
    if diva_algorithm
      algorithm.update_attribute(:diva_id, diva_algorithm.id)
      algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
    else
      algorithm.set_status(:error, "Publication could not be started, just try again.\n Please send this to the devs: \"#{diva_algorithm}\"")
    end
  rescue Errno::ECONNREFUSED => error
    algorithm.set_status(:connection_error, 'The DIVAServices cannot be reached at the moment. Please try again later.')
  end

  ##
  # Updates the given _algorithm_ on the DIVAServices
  def update(algorithm)
    p 'Updating algorithm' if Rails.env.development?
    old_diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.predecessor.diva_id)
    diva_algorithm = old_diva_algorithm.update(algorithm.to_schema)
    if diva_algorithm
      algorithm.update_attribute(:diva_id, diva_algorithm.id)
      algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
    else
      algorithm.set_status(:error, "Updating could not be started, just try again.\n Please send this to the devs: \"#{diva_algorithm}\"")
    end
  rescue Errno::ECONNREFUSED => error
    algorithm.set_status(:connection_error, 'The DIVAServices cannot be reached at the moment. Please try again later.')
  end
end
