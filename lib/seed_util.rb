##
# Contains all helper methods used in /db/seeds.rb.
module SeedUtil

  ##
  # Helps to find a certail field of an _algorithm_.
  def find_field(source, name)
    fields = Field.where(fieldable_id: source.id)
    field = fields.where("payload->>'name' = ?", name).first
  end
end
