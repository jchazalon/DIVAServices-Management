class StringField < Field

  content_attr :minLength, :integer
  content_attr :maxLength, :integer
  content_attr :format, :string
  content_attr :regex, :string

  validate :minimal_length
  validate :maximal_length
  validate :match_regex
  validates :value, email: { strict_mode: true, message: 'Invalid email address!' }, if: '!self.value.empty? && self.format && self.format.eql?("email")'
  validates :value, url: { allow_nil: true, allow_blank: true, no_local: true }, if: '!self.value.empty? && self.format && self.format.eql?("uri")'

  def match_regex
    if !self.value.empty? && self.regex
      errors.add(:value, 'is a invalid value') unless self.value =~ Regexp.new(self.regex)
    end
  end

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
    params['regex'] = v['regex']
    return params
  end

  def object_type
    'string'
  end
end
