class PublishAlgorithmJob < ActiveJob::Base
  queue_as :default

  def perform(algorithm_id)
    algorithm = Algorithm.find(algorithm_id)
    if algorithm

      p 'Calling /management/algorithm'
      p DivaServiceApi.publish_algorithm(algorithm)
      
      p 'Update status to published'
      algorithm.update_attribute(:creation_status, :published)
    else
      p 'Algorithm not found!'
    end
  end
end
