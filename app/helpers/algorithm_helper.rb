module AlgorithmHelper

  def previous_versions(algorithm)
    versions = Array.new
    begin
      algorithm = current_user.algorithms.where(next: algorithm).first
      versions << algorithm if algorithm
    end while(algorithm)
    versions
  end

  def executions(algorithm)
    diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.diva_id)
    if diva_algorithm
      diva_algorithm.executions
    else
      '-'
    end
  end

  def exceptions(algorithm)
    diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.diva_id)
    if diva_algorithm
      diva_algorithm.exceptions.size
    else
      '-'
    end
  end
end
