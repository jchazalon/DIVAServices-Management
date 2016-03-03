class ObjectField < Field
  has_many :fields, class_name: 'Field', foreign_key: 'field_id'

  def self.create_from_hash(k,v)
    return super(k,v)
  end
end
