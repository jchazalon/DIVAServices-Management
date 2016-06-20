##
# Field used to store booleans.
class BooleanField < Field

  #TODO that can be removed, right?
  def self.create_from_hash(k,v)
    return super(k,v)
  end

  def object_type
    'boolean'
  end

  def value_to_schema
    self.value.to_b
  end
end
