class StringField < Field

  content_attr :minLength, :integer
  content_attr :maxLength, :integer
  content_attr :format, :string

  validate :minimal_length
  validate :maximal_length
  validates :value, email: { strict_mode: true, message: 'Invalid email address!' }, if: '!self.value.empty? && self.format && self.format.eql?("email")'
  validates :value, url: { allow_nil: true, allow_blank: true, no_local: true }, if: '!self.value.empty? && self.format && self.format.eql?("uri")'

  def minimal_length
    if !self.value.empty? && self.minLength
      errors.add(:value, 'is too short!') if self.value.length < self.minLength
    end
  end

  def maximal_length
    if !self.value.empty? && self.maxLength
      errors.add(:value, 'is too long!') if self.value.length > self.maxLength
    end
  end

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['minLength'] = v['minLength']
    params['maxLength'] = v['maxLength']
    params['format'] = v['format']
    return params
  end

  def object_type
    'string'
  end
end
