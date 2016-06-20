##
# Field used to store Strings.
class StringField < Field

  content_attr :minLength, :integer
  content_attr :maxLength, :integer
  content_attr :format, :string
  content_attr :regex, :string
  content_attr :multiline, :boolean

  validate :minimal_length
  validate :maximal_length
  validate :match_regex
  validates :value, email: { strict_mode: true, message: 'Invalid email address!' }, if: '!self.value.blank? && self.format && self.format.eql?("email")'
  validates :value, url: { allow_nil: true, allow_blank: true, no_local: true }, if: '!self.value.blank? && self.format && self.format.eql?("uri")'

  ##
  # Validates if the value matches the given regex rule.
  def match_regex
    if !self.value.blank? && self.regex
      errors.add(:value, 'is a invalid value') unless self.value =~ Regexp.new(self.regex)
    end
  end

  ##
  # Validates if the string contains a minimal amount of characters.
  def minimal_length
    if !self.value.blank? && self.minLength
      errors.add(:value, 'is too short!') if self.value.length < self.minLength
    end
  end

  ##
  # Validates if the string doesn't exceeds a maximal amount of characters.
  def maximal_length
    if !self.value.blank? && self.maxLength
      errors.add(:value, 'is too long!') if self.value.length > self.maxLength
    end
  end

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['minLength'] = v['minLength']
    params['maxLength'] = v['maxLength']
    params['format'] = v['format']
    params['regex'] = v['regex']
    params['multiline'] = v['multiline']
    return params
  end

  def object_type
    if self.multiline
      'text'
    else
      'string'
    end
  end
end
