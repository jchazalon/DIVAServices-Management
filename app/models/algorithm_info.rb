class AlgorithmInfo < ActiveRecord::Base

  belongs_to :algorithm

  def self.content_attr(attr_name, attr_type = :string)
    content_attributes[attr_name] = attr_type

    define_method(attr_name) do
      self.payload ||= {}
      self.payload[attr_name.to_s]
    end

    define_method("#{attr_name}=".to_sym) do |value|
      self.payload ||= {}
      self.payload[attr_name.to_s] = value
      self.payload_will_change!
      self.save!
    end
  end

  def self.content_attributes
    @content_attributes ||= {}
  end

  def self.algorithm_info_attributes
    {author: :string, email: :string, website: :string}
  end

  algorithm_info_attributes.each do |k,v|
    content_attr k, v
  end
end
