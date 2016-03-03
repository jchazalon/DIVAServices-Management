class ObjectField < Field
  has_many :fields, class_name: 'Field', foreign_key: 'field_id'
end
