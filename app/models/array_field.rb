##
# Field used to store arrays.
class ArrayField < Field

  content_attr :minItems, :integer
  content_attr :uniqueItems, :boolean

  validate :minimal_items
  validate :unique_items

  ##
  # Validates that the items are unique.
  def unique_items
    if !self.value.blank? && self.minItems
      errors.add(:value, "cannot contain a element twice!") if self.value.split(';').uniq.length != self.value.split(';').length
    end
  end

  ##
  # Validates the minimal amount of items necessary.
  def minimal_items
    if !self.value.blank? && self.minItems
      errors.add(:value, "must contain at least #{self.minItems} element(s)!") if self.value.split(';').size < self.minItems
    end
  end

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['infoText'] += ' | Seperate the individual values with a ";" (No spaces between)'
    params['minItems'] = v['minItems']
    params['uniqueItems'] = v['uniqueItems']
    return params
  end

  ##
  # Overwrites the default getter of value so that an array is returned instead of a string.
  def value
      value = super()
      value.join(';') unless value.blank?
  end

  ##
  # Overwrites the default setter of value so that the array is stored as a string.
  def value=(value)
    value = value.split(';')
    super(value)
  end

  def object_type
    'string'
  end

  def value_to_schema
    self.value.split(';')
  end
end
