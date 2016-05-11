class EnumField < Field

  content_attr :values, :string
  content_attr :keys, :string

  validate :valid_selection

  def valid_selection
    if !self.value.empty?
      errors.add(:value, 'cannot be selected!') unless self.values.include?(self.value)
    end
  end

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['values'] = v['values']
    params['keys'] = v['keys']
    return params
  end

  def object_type
    if self.values.size > 4
      'select'
    else
      'radio_buttons'
    end
  end

  def collection
    self.values.each_with_index.map{ |v,i| [self.keys[i], v] }
  end
end
