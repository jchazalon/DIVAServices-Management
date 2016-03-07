class DivaServiceApi

  def self.available_languages
    #TODO parse language_types directly from API
    data = JSON.parse(File.read(Rails.root.join('language_types.json')))
    [*data]
  end

  def self.available_output_types
    #TODO parse output_types directly from API
    data = JSON.parse(File.read(Rails.root.join('output_types.json')))
    [*data]
  end

  def self.available_input_types
    #TODO parse input_types directly from API
    data = JSON.parse(File.read(Rails.root.join('input_types.json')))
    [*data.keys]
  end

  def self.input_types
    JSON.parse(File.read(Rails.root.join('input_types.json')))
  end

  def self.additional_information
    JSON.parse(File.read(Rails.root.join('additional_info.json')))
  end

end
