class EnumField < Field

  content_attr :values, :string

  validate :valid_selection

  def valid_selection
    if !self.value.empty?
      errors.add(:value, 'cannot be selected!') unless self.values.include?(self.value)
    end
  end

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['values'] = v['values']
    return params
  end

  def object_type
    'radio_buttons'
  end
end
