class ObjectField < Field

  has_many :fields, as: :fieldable, dependent: :destroy

  accepts_nested_attributes_for :fields, allow_destroy: :true

  def self.create_from_hash(k,v)
    return super(k,v)
  end

  def all_fields
    found_fields = Array.new
    self.fields.each do |field|
      found_fields << field
      found_fields = found_fields + field.all_fields if field.type == 'ObjectField'
    end
    found_fields
  end
end
