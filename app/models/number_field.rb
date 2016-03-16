class NumberField < Field

  def self.create_from_hash(k,v)
    return super(k,v)
  end

  def object_type
    'float'
  end

  def value_to_schema
    number = self.value.to_f
    if number % 1 == 0
      number.to_i
    else
      number
    end
  end
end
