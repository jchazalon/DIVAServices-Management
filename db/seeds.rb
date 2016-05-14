include SeedUtil
include DivaServicesApi

############
#Clean up first
############
#NOTE Remove all previously uploaded files
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

############
#Users
############
user = User.create!(email: 'dev@diva.unifr.ch', password: '12345678')

if !DivaServicesApi.is_online?
  p '----------------------------------------------'
  p '--------          WARNING!!           --------'
  p '----------------------------------------------'
  p "DIVAServices is offline, can't seed algorithms"
  p '----------------------------------------------'
else
  ############
  #Algorithm 1
  ############
  algorithm1 = user.algorithms.create!(status: :empty)
  algorithm1.general_field('name').value = 'Canny Edge Detection'
  algorithm1.general_field('description').value = 'Who knows, I always only read candy detection ;)'
  algorithm1.general_field('author').value = 'DIVA UniFr'
  algorithm1.general_field('email').value = 'dev@diva.unifr.ch'
  algorithm1.general_field('website').value = 'http://www.unifr.ch'
  algorithm1.general_field('type').value = 'OCR'
  algorithm1.update_attribute(:zip_file, File.open(File.join(Rails.root, 'cannyedgedetection.zip')))
  algorithm1.output_field('output_type').value = 'file'
  algorithm1.method_field('language').value = 'java'
  algorithm1.method_field('environment').value = 'java:8'
  algorithm1.method_field('executable_path').value = 'cannyedgedetection/cannyedgedetection.jar'
  algorithm1.update_attribute(:status, :review)
  algorithm1.save!

  # InputParameters
  input_parameter1 = algorithm1.input_parameters.create!(input_type: 'inputImage')
  input_parameter2 = algorithm1.input_parameters.create!(input_type: 'outputFolder')

  ############
  #Algorithm 2
  ############
  algorithm2 = user.algorithms.create!(status: :empty)
  algorithm2.general_field('name').value = 'Noising'
  algorithm2.general_field('description').value = 'Noises the image I guess?!'
  algorithm2.general_field('author').value = 'DIVA UniFr'
  algorithm2.general_field('DOI').value = 'doi:10.1000/182'
  algorithm2.general_field('email').value = 'dev@diva.unifr.ch'
  algorithm2.general_field('website').value = 'http://www.unifr.ch'
  algorithm2.general_field('type').value = 'OCR'
  algorithm2.update_attribute(:zip_file, File.open(File.join(Rails.root, 'noising.zip')))
  algorithm2.output_field('output_type').value = 'file'
  algorithm2.method_field('language').value = 'java'
  algorithm2.method_field('environment').value = 'java:8'
  algorithm2.method_field('executable_path').value = 'noising/noising.jar'
  algorithm2.update_attribute(:status, :review)
  algorithm2.save!

  ############
  #Algorithm 3
  ############
  algorithm3 = user.algorithms.create!(status: :empty)
  algorithm3.general_field('name').value = 'Canny Edge Detection'
  algorithm3.general_field('description').value = 'Who knows, I always only read candy detection ;)'
  algorithm3.general_field('author').value = 'DIVA UniFr'
  algorithm3.general_field('email').value = 'dev@diva.unifr.ch'
  algorithm3.general_field('website').value = 'http://www.unifr.ch'
  algorithm3.general_field('type').value = 'OCR'
  algorithm3.update_attribute(:zip_file, File.open(File.join(Rails.root, 'dummy.zip')))
  algorithm3.output_field('output_type').value = 'file'
  algorithm3.method_field('language').value = 'java'
  algorithm3.method_field('environment').value = 'java:8'
  algorithm3.method_field('executable_path').value = 'empty'
  algorithm3.update_attribute(:status, :review)
  algorithm3.save!

  # InputParameters
  input_parameter1 = algorithm3.input_parameters.create!(input_type: 'inputImage')

  input_parameter2 = algorithm3.input_parameters.create!(input_type: 'text')
  SeedUtil.find_field(input_parameter2, 'name').value = 'bananaPhone'
  SeedUtil.find_field(input_parameter2, 'description').value = 'Idk, just some fancy variable name'
  SeedUtil.find_field(SeedUtil.find_field(input_parameter2, 'options'), 'required').value = true
  SeedUtil.find_field(SeedUtil.find_field(input_parameter2, 'options'), 'min').value = 1
  SeedUtil.find_field(SeedUtil.find_field(input_parameter2, 'options'), 'max').value = 100
  SeedUtil.find_field(SeedUtil.find_field(input_parameter2, 'options'), 'default').value = 'ring ring'

  input_parameter3 = algorithm3.input_parameters.create!(input_type: 'inputImage')

  input_parameter4 = algorithm3.input_parameters.create!(input_type: 'outputImage')

  input_parameter5 = algorithm3.input_parameters.create!(input_type: 'number')
  SeedUtil.find_field(input_parameter5, 'name').value = 'minBlockWidth'
  SeedUtil.find_field(input_parameter5, 'description').value = 'Minimal block width'
  SeedUtil.find_field(SeedUtil.find_field(input_parameter5, 'options'), 'required').value = true
  SeedUtil.find_field(SeedUtil.find_field(input_parameter5, 'options'), 'min').value = 1
  SeedUtil.find_field(SeedUtil.find_field(input_parameter5, 'options'), 'max').value = 100
  SeedUtil.find_field(SeedUtil.find_field(input_parameter5, 'options'), 'steps').value = 10
  SeedUtil.find_field(SeedUtil.find_field(input_parameter5, 'options'), 'default').value = 50

  input_parameter6 = algorithm3.input_parameters.create!(input_type: 'text')
  SeedUtil.find_field(input_parameter6, 'name').value = 'searchText'
  SeedUtil.find_field(input_parameter6, 'description').value = 'Text to seach for'
  SeedUtil.find_field(SeedUtil.find_field(input_parameter6, 'options'), 'required').value = true
  SeedUtil.find_field(SeedUtil.find_field(input_parameter6, 'options'), 'min').value = 1
  SeedUtil.find_field(SeedUtil.find_field(input_parameter6, 'options'), 'max').value = 1000
  SeedUtil.find_field(SeedUtil.find_field(input_parameter6, 'options'), 'default').value = 'Hello World'

  input_parameter7 = algorithm3.input_parameters.create!(input_type: 'select')
  SeedUtil.find_field(input_parameter7, 'name').value = 'algorithmVersion'
  SeedUtil.find_field(input_parameter7, 'description').value = 'What version of the algorithm should be used'
  SeedUtil.find_field(SeedUtil.find_field(input_parameter7, 'options'), 'required').value = true
  SeedUtil.find_field(SeedUtil.find_field(input_parameter7, 'options'), 'values').value = ['v1', 'v2', 'v3', 'legacy']
  SeedUtil.find_field(SeedUtil.find_field(input_parameter7, 'options'), 'default').value = 0

  input_parameter8 = algorithm3.input_parameters.create!(input_type: 'highlighter')
  SeedUtil.find_field(input_parameter8, 'type').value = 'circle'

end
