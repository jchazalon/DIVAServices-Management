module SeedUtil
  def find_field(source, name)
    fields = Field.where(fieldable_id: source.id)#, fieldable_type: result.class.name)
    field = fields.where("payload->>'name' = ?", name).first
  end
end
