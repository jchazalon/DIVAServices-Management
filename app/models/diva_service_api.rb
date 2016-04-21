class DivaServiceApi
  include HTTParty
  base_uri 'localhost:8080'
  default_timeout 15
  format :json

  #TODO DEV temporary solution
  def self.mock_languages
    mock_to_hash({ java: { infoText: "Java" }, coffeescript: { infoText: "Coffeescript" }, bash: { infoText: "Simple command-line" } })
  end

  def self.mock_environments
    mock_to_hash({ :"java:7" => { infoText: "Java 7" }, :"java:8" => { infoText: "Java 8" } })
  end

  #TODO DEV temporary solution
  def self.mock_output_types
    mock_to_hash({ file: { infoText: "Store output into a file. Requires to use a outputFile parameter!" }, console: { infoText: "Returns output to the standard output" } })
  end

  def self.mock_to_hash(mock)
    hash = Hash.new
    [*mock.keys].each do |key|
      hash[key] = mock[key][:infoText]
    end
    return hash.invert
  end

  def self.languages
    begin
      response = self.get('/info/languages')
      if response.success?
        ############################return response.parsed_response #XXX fix
        return mock_languages
      else #TODO 404, 500 or something like that, what happens?
        return mock_languages
      end
    rescue Errno::ECONNREFUSED => e #TODO API offline? what happens?
      p e
      return mock_languages
    end
  end

  def self.environments
    begin
      response = self.get('/info/environments')
      if response.success?
        return response.parsed_response
      else #TODO 404, 500 or something like that, what happens?
        return mock_environments
      end
    rescue Errno::ECONNREFUSED => e #TODO API offline? what happens?
      p e
      return mock_environments
    end
  end

  def self.available_output_types
    begin
      response = self.get('/info/outputs')
      if response.success?
        ############################return response.parsed_response #XXX fix
        return mock_output_types
      else #TODO 404, 500 or something like that, what happens?
        return mock_output_types
      end
    rescue Errno::ECONNREFUSED => e #TODO API offline? what happens?
      p e
      return mock_output_types
    end
  end

  def self.input_types
    response = self.get('/info/inputs')
    return response.parsed_response if response.success?
  end

  def self.additional_information
    begin
      response = self.get('/info/additional')
      if response.success?
        return response.parsed_response
      else #TODO 404, 500 or something like that, what happens?
        return {}
      end
    rescue Errno::ECONNREFUSED => e #TODO API offline? what happens?
      p e
      return {}
    end
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

  def self.validate_algorithm(algorithm)
    self.post('/validate/create', body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end

  def self.publish_algorithm(algorithm)
    self.post('/management/algorithms', body: algorithm.to_schema, headers: { 'Content-Type' => 'application/json' })
  end
end
