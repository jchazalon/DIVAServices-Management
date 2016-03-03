class ArrayField < Field

  content_attr :minItems, :integer
  content_attr :uniqueItems, :boolean
  #TODO item type!

  def self.create_from_hash(k,v)
    params = super(k,v)
    params['minItems'] = v['minItems']
    params['uniqueItems'] = v['uniqueItems']
    return params
  end
end
