class ObjectField < Field

  has_many :fields, as: :fieldable, dependent: :destroy

  accepts_nested_attributes_for :fields, allow_destroy: :true

  def self.create_from_hash(k,v)
    return super(k,v)
  end

  def to_schema
    data = Hash.new
    self.fields.each do |field|
      if field.type == 'ObjectField'
        data[field.name] = field.to_schema
      else
        data[field.name] = field.value_to_schema unless field.value.blank?
      end
    end
    return data
  end

  def deep_copy
    field_copy = self.dup
    self.fields.each do |field|
      field_copy.fields << field.deep_copy
    end
    field_copy.save!
    field_copy
  end

  def anything_changed?
    self.fields.each do |field|
      return true if field.anything_changed?
    end
    return false;
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
