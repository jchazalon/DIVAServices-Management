class ObjectField < Field
  has_many :fields, class_name: 'Field', foreign_key: 'field_id'

  accepts_nested_attributes_for :fields, allow_destroy: :true

  def self.create_from_hash(k,v)
    return super(k,v)
  end
end
