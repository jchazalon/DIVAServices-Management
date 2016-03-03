class StringField < Field

  content_attr :minLength, :integer
  content_attr :maxLength, :integer

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['minLength'] = v['minLength']
    params['maxLength'] = v['maxLength']
    return params
  end
end
