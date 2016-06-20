module AlgorithmHelper

  ##
  # Returns an array containing all previous versions of the given _algorithm_.
  def previous_versions(algorithm)
    versions = Array.new
    begin
      algorithm = current_user.algorithms.where(next: algorithm).first
      versions << algorithm if algorithm
    end while(algorithm)
    versions
  end
end
