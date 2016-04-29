class DivaServiceApi
  include HTTParty
  base_uri 'localhost:8080'
  default_timeout 300
  format :json

  def self.languages
    begin
      response = self.get('/info/language')
      if response.success?
        languages = Hash.new
        response.parsed_response.keys.each do |k|
          languages[k] = response.parsed_response[k]['infoText']
        end
      return languages.invert
      end
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return {}
  end

  def self.environments
    begin
      response = self.get('/info/environments')
      if response.success?
        environments = Hash.new
        response.parsed_response.keys.each do |k|
          environments[k] = response.parsed_response[k]['infoText']
        end
      return environments.invert
      end
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return {}
  end

  def self.available_output_types
    begin
      response = self.get('/info/outputs')
      if response.success?
        outputs = Hash.new
        response.parsed_response.keys.each do |k|
          outputs[k] = response.parsed_response[k]['infoText']
        end
      return outputs.invert
      end
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return {}
  end

  def self.input_types
    begin
      response = self.get('/info/inputs')
      return response.parsed_response if response.success?
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return {}
  end

  def self.additional_information
    begin
      response = self.get('/info/additional')
      return response.parsed_response if response.success?
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return {}
  end

  def self.status(diva_id)
    begin
      response = self.get("/algorithms/#{diva_id}")
      return response.parsed_response if response.success?
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return {}
  end

  def self.delete_algorithm(algorithm)
    #TODO What happens if there is no diva_id??
    begin
      response = self.delete("/algorithms/#{algorithm.diva_id}")
      return true if response.success?
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return false
  end

  def self.validate_algorithm(algorithm)
    self.post('/validate/create', body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end

  def self.publish_algorithm(algorithm)
    self.post('/algorithms', body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end

  def self.available_input_types
    data = DivaServiceApi.input_types
    [*data.keys]
  end

  def self.input_type_descriptions
    data = DivaServiceApi.input_types
    hash = Hash.new
    available_input_types.each do |input_type|
      hash[input_type] = data[input_type]['infoText']
    end
    hash
  end
end
