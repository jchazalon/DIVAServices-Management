##
# API wrapper module created to address the DIVAServices in a single point.
# All API requests must be performed here!
module DivaServicesApi
  include HTTParty

  base_uri ENV['DIVA_SERVICES_HOST']
  format :json

  ##
  # Returns true if the DIVAServices API is accessable, otherwise returns false
  def self.is_online?
    begin
      response = self.get('/')
      return true if response.success?
    rescue Errno::ECONNREFUSED => e
      # Catching exceptions and doing nothing is like ignoring global warming, everybody does it ;)
    end
    return false
  end
end
