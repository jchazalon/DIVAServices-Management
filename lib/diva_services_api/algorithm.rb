module DivaServicesApi

  ##
  # Wrapper around the _algorithm_ information that is transmitted between the two services.
  class Algorithm

    attr_accessor :id, :status_code, :status_message, :executions

    ##
    # Read out the status of the algorithm from the DivaServices.
    # Note that the status is always served as a number (e.g. 200 or 500).
    def status_code
      DivaServicesApi::Algorithm.by_id(self.id, self) if @status_code == nil
      @status_code
    end

    ##
    # Read out the corresponding status message if available.
    def status_message
      DivaServicesApi::Algorithm.by_id(self.id, self) if @status_message == nil
      @status_message
    end

    ##
    # Receive all exceptions and return a collection of DivaServicesApi#ExceptionMessage.
    def exceptions
      exceptions = DivaServicesApi.get("/algorithms/#{id}/exceptions").parsed_response
      exceptions.map do |entry|
        DivaServicesApi::ExceptionMessage.new(id, DateTime.parse(entry['date']), entry['errorMessage'])
      end
    end

    ##
    # Create a new instance.
    def initialize(id)
      self.id = id
    end

    ##
    # Load the information of an _algorithm_ based on an DivaServices algorithm id.
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

    ##
    # Access the /information/general route
    def self.general_information
      DivaServicesApi.get('/information/general').parsed_response
    end

    ##
    # Access the /information/input route
    def self.input_information
      DivaServicesApi.get('/information/input').parsed_response
    end

    ##
    # Access the /information/output route
    def self.output_information
      DivaServicesApi.get('/information/output').parsed_response
    end

    ##
    # Access the /information/method route
    def self.method_information
      DivaServicesApi.get('/information/method').parsed_response
    end

    ##
    # Create a collection containing tuples like e.g. ['Input Image', 'input_image'].
    def self.input_type_keys_with_names
      DivaServicesApi::Algorithm.input_information.map do |input_type|
        [input_type[1]['displayText'], input_type[0]]
      end
    end

    ##
    # Create a collection containing hashes like e.g. {hint: 'Image that is used for ...', name: 'Input Image'}.
    def self.list_input_types
      info = DivaServicesApi::Algorithm.input_information
      DivaServicesApi::Algorithm.input_information.keys.map do |input_type|
        { hint: info[input_type]['infoText'], name: info[input_type]['displayText'] }
      end
    end

    ##
    # Validate the given json against the algorithm schema.
    # Returns true if the json is valid on the DIVAServices
    def self.validate(json)
      DivaServicesApi.post('/validate/create', body: json, headers: { 'Content-Type' => 'application/json' }).success?
    end

    ##
    # Returns the message received from the DIVAServices after it failed the validation!
    # Note that this method should not be used on valid validations!
    def self.validation_message(json)
      response = DivaServicesApi.post('/validate/create', body: json, headers: { 'Content-Type' => 'application/json' })
      return response['message']
    end

    ##
    # Publish a new algorithm with the given json schema.
    def self.publish(json)
      response = DivaServicesApi.post('/algorithms', body: json, headers: { 'Content-Type' => 'application/json' })
      DivaServicesApi::Algorithm.new(response['identifier'])
    end

    ##
    # Update an existing algorithm with the given json schema.
    def update(json)
      response = DivaServicesApi.put("/algorithms/#{self.id}", body: json, headers: { 'Content-Type' => 'application/json' })
      DivaServicesApi::Algorithm.new(response['identifier'])
    end

    ##
    # Remove an existing algorithm from the DIVAServices.
    def delete
      response = DivaServicesApi.delete("/algorithms/#{self.id}")
      response.success?
    end
  end
end
