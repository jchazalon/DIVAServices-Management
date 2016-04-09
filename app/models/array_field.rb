class ArrayField < Field

  content_attr :minItems, :integer
  content_attr :uniqueItems, :boolean

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['infoText'] += ' | Seperate the individual values with a ";"'
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
