module AlgorithmHelper

  ##
  # Returns an array containing all previous versions of the given _algorithm_.
  def previous_versions(algorithm)
    versions = Array.new
    begin
      algorithm = current_user.algorithms.where(next: algorithm).first
      versions << algorithm if algorithm
    end while(algorithm)
    # Do not list the most previous version, because thats simply the backup of the current one!
    versions[1..-1] # [1..-1] means all elements, except the first one. 0 means first, -1 means last
  end

  ##
  # Exchanges the raw status with a more user friendly description.
  def pretty_status(algorithm)
    case algorithm.status.to_sym
    when *Algorithm.wizard_steps[0..-2]
      return 'Currently in wizard'
    when :review
      return 'Needs review'
    when :connection_error
      return 'No connection to DIVAServices'
    else
     return algorithm.status.humanize
    end
  end
end
