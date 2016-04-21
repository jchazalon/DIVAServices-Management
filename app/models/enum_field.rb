class EnumField < Field

  content_attr :values, :string

  #TODO validate :values, inclusion: { in: ? }

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['values'] = v['values']
    return params
  end

  def object_type
    'radio_buttons'
  end
end
