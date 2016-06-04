module DivaServicesApi
  class ExceptionMessage

    attr_accessor :algorithm_id, :datetime, :message

    def initialize(algorithm_id, datetime, message)
      self.algorithm_id = algorithm_id
      self.datetime = datetime
      self.message = message
    end
  end
end
