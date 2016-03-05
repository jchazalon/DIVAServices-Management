class BooleanField < Field

  def self.create_from_hash(k,v)
    return super(k,v)
  end

  def object_type
    'boolean'
  end
end
