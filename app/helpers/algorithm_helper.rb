module AlgorithmHelper

  def previous_versions(algorithm)
    versions = Array.new
    begin
      algorithm = current_user.algorithms.where(next: algorithm).first
      versions << algorithm if algorithm
    end while(algorithm)
    versions
  end
end
