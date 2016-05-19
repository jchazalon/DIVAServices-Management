module DivaServicesApi
  class Algorithm

    attr_accessor :id, :status_code, :status_message, :executions

    def status_code
      DivaServicesApi::Algorithm.by_id(self.id, self) if @status_code == nil
      @status_code
    end

    def status_message
      DivaServicesApi::Algorithm.by_id(self.id, self) if @status_message == nil
      @status_message
    end

    def initialize(id)
      self.id = id
    end

    def self.by_id(id, algorithm = nil)
      response = DivaServicesApi.get("/algorithms/#{id}")
      if response.success?
        algorithm = self.new(id) unless algorithm
        algorithm.status_code = response['status']['statusCode']
        algorithm.status_message = response['status']['statusMessage']
        algorithm.executions = response['statistics']['executions']
        algorithm
      else
        nil
      end
    end

    def self.general_information
      DivaServicesApi.get('/information/general').parsed_response
    end

    def self.input_information
      DivaServicesApi.get('/information/input').parsed_response
    end

    def self.output_information
      DivaServicesApi.get('/information/output').parsed_response
    end

    def self.method_information
      DivaServicesApi.get('/information/method').parsed_response
    end

    def self.input_type_keys
      DivaServicesApi::Algorithm.input_information.keys
    end

    def self.input_type_descriptions
      data = DivaServicesApi::Algorithm.input_information
      hash = Hash.new
      DivaServicesApi::Algorithm.input_type_keys.each do |input_type|
        hash[input_type] = data[input_type]['infoText']
      end
      hash
    end

    def self.validate(json)
      DivaServicesApi.post('/validate/create', body: json, headers: { 'Content-Type' => 'application/json' })
    end

    def self.publish(json)
      response = DivaServicesApi.post('/algorithms', body: json, headers: { 'Content-Type' => 'application/json' })
      self.new(response['identifier'])
    end

    def update(id, json)
      response = DivaServicesApi.put("/algorithms/#{id}", body: json, headers: { 'Content-Type' => 'application/json' })
      DivaServicesApi::Algorithm.new(response['identifier'])
    end

    def delete
      response = DivaServicesApi.delete("/algorithms/#{self.id}")
      response.success?
    end
  end
end
