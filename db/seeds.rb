include SeedUtil
include DivaServicesApi

##
# Clean up first, remove all entries from the database.
FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads"])
CarrierWave.clean_cached_files!
User.destroy_all
Algorithm.destroy_all
InputParameter.destroy_all
Field.destroy_all
StringField.destroy_all
BooleanField.destroy_all
ObjectField.destroy_all
EnumField.destroy_all
ArrayField.destroy_all
NumberField.destroy_all
Delayed::Job.destroy_all

##
# Create user accounts
user1 = User.create!(email: 'dev@diva.unifr.ch', password: '12345678')
user2 = User.create!(email: 'user@diva.unifr.ch', password: '12345678')
user3 = User.create!(email: 'admin@diva.unifr.ch', password: '12345678', admin: true)

case Rails.env
when "production"
  # Seed production, currently nothing.
when "development"
  # Seed development, first check that the DIVAServices is reachable!
  if !DivaServicesApi.is_online?
    p '----------------------------------------------'
    p '--------          WARNING!!           --------'
    p '----------------------------------------------'
    p "DIVAServices is offline, can't seed algorithms"
    p '----------------------------------------------'
  else
    ##
    # Create dummy algorithm 1. This one works actually.
  end
end
