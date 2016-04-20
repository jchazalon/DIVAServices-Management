class ArrayField < Field

  content_attr :minItems, :integer
  content_attr :uniqueItems, :boolean

  validate :minimal_items
  validate :unique_items

  def unique_items
    if !self.value.empty? && self.minItems
      errors.add(:value, "cannot contain a element twice!") if self.value.split(';').uniq.length != self.value.split(';').length
    end
  end

  def minimal_items
    if !self.value.empty? && self.minItems
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

  def value
      value = super()
      value.join(';')
  end

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
