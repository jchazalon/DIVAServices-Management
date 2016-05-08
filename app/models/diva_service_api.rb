class DivaServiceApi
  include HTTParty
  base_uri 'localhost:8080'
  default_timeout 300 #XXX Way too long
  format :json

  def self.is_online?
    begin
      response = self.get('/')
      return true if response.success?
    rescue Errno::ECONNREFUSED => e
      #XXX Catching exceptions and doing nothing is like ignoring global warming
    end
    return false
  end

  def self.get_information(route)
    response = self.get(route)
    if response.success?
      return response.parsed_response
    else
      raise DivaServiceError
    end
  end

  def self.general_information
    self.get_information('/information/general')
  end

  def self.input_information
    self.get_information('/information/input')
  end

  def self.output_information
    self.get_information('/information/output')
  end

  def self.method_information
    self.get_information('/information/method')
  end

  def self.input_type_keys
    DivaServiceApi.input_information.keys
  end

  def self.input_type_descriptions
    data = DivaServiceApi.input_information
    hash = Hash.new
    self.input_type_keys.each do |input_type|
      hash[input_type] = data[input_type]['infoText']
    end
    hash
  end

  def self.status(diva_id)
    self.get_information("/algorithms/#{diva_id}")
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
    #TODO self.post("/algorithms/#{algorithm.diva_id}", body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end
end
