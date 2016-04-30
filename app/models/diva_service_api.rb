class DivaServiceApi
  include HTTParty
  base_uri 'localhost:8080'
  default_timeout 300
  format :json

  def self.is_online?
    begin
      response = self.get('/info/language')
      return true if response.success?
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return false
  end

  def self.languages
    response = self.get('/info/language')
    if response.success?
      languages = Hash.new
      response.parsed_response.keys.each do |k|
        languages[k] = response.parsed_response[k]['infoText']
      end
      return languages.invert
    else
      raise DivaServiceError
    end
  end

  def self.environments
    response = self.get('/info/environments')
    if response.success?
      environments = Hash.new
      response.parsed_response.keys.each do |k|
        environments[k] = response.parsed_response[k]['infoText']
      end
      return environments.invert
    else
      raise DivaServiceError
    end
  end

  def self.output_types
    response = self.get('/info/outputs')
    if response.success?
      outputs = Hash.new
      response.parsed_response.keys.each do |k|
        outputs[k] = response.parsed_response[k]['infoText']
      end
      return outputs.invert
    else
      raise DivaServiceError
    end
  end

  def self.input_types
    response = self.get('/info/inputs')
    if response.success?
      return response.parsed_response
    else
      raise DivaServiceError
    end
  end

  def self.input_type_keys
    DivaServiceApi.input_types.keys
  end

  def self.input_type_descriptions
    data = DivaServiceApi.input_types
    hash = Hash.new
    input_types.keys.each do |input_type|
      hash[input_type] = data[input_type]['infoText']
    end
    hash
  end

  def self.additional_information
    response = self.get('/info/additional')
    if response.success?
      return response.parsed_response
    else
      raise DivaServiceError
    end
  end

  def self.status(diva_id)
    response = self.get("/algorithms/#{diva_id}")
    if response.success?
      return response.parsed_response
    else
      raise DivaServiceError
    end
  end

  def self.delete_algorithm(algorithm)
    response = self.delete("/algorithms/#{algorithm.diva_id}")
    if response.success? && algorithm.diva_id != nil
      return true
    else
      return false
    end
  end

  def self.validate_algorithm(algorithm)
    self.post('/validate/create', body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end

  def self.publish_algorithm(algorithm)
    self.post('/algorithms', body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end
end
