class DivaServiceApi
  include HTTParty
  base_uri 'localhost:8080'
  default_timeout 15
  format :json

  def self.available_languages
    #TODO catch if API offline?
    # begin
      response = self.get('/info/languages')
      return response.parsed_response if response.success?
    # rescue => e
    #   p "API offline #{e}"
    #   data = JSON.parse(File.read(Rails.root.join('language_types.json')))
    #   return [*data]
    # end
  end

  def self.available_output_types
    response = self.get('/info/outputs')
    return response.parsed_response if response.success?
  end

  def self.input_types
    response = self.get('/info/inputs')
    return response.parsed_response if response.success?
  end

  def self.additional_information
    response = self.get('/info/additional')
    return response.parsed_response if response.success?
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
