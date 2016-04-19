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

user = User.create!(email: 'dev@diva.unifr.ch', password: '12345678')

############
#Algorithm 1
############
algorithm1 = user.algorithms.create!(name: 'Canny Edge Detection', namespace: 'diva', description: 'Who knows, I always onyl read candy detection ;)', creation_status: :empty)
algorithm1.additional_information_with('author').value = 'DIVA'
algorithm1.additional_information_with('email').value = 'dev@diva.unifr.ch'
algorithm1.additional_information_with('website').value = 'http://www.unifr.ch'
algorithm1.update_attribute(:zip_file, File.open(File.join(Rails.root, 'cannyedgedetection.zip')))
algorithm1.update_attribute(:executable_path, 'cannyedgedetection/cannyedgedetection.jar')
algorithm1.output = DivaServiceApi.available_output_types[1]
algorithm1.language = DivaServiceApi.available_languages[1]
algorithm1.update_attribute(:environment, 'java:8')
algorithm1.update_attribute(:creation_status, :review)
algorithm1.save!

# InputParameters
input_parameter1 = algorithm1.input_parameters.create!(input_type: 'inputImage')
input_parameter2 = algorithm1.input_parameters.create!(input_type: 'outputFolder')

############
#Algorithm 2
############
algorithm2 = user.algorithms.create!(name: 'Noising', namespace: 'diva', description: 'Noises the image I guess?!', creation_status: :empty)
algorithm2.additional_information_with('author').value = 'DIVA'
algorithm2.additional_information_with('DOI').value = 'doi:10.1000/182'
algorithm2.additional_information_with('purpose').value = 'Just for fun'
algorithm2.additional_information_with('email').value = 'dev@diva.unifr.ch'
algorithm2.additional_information_with('website').value = 'http://www.diva.unifr.ch'
algorithm2.update_attribute(:zip_file, File.open(File.join(Rails.root, 'noising.zip')))
algorithm2.update_attribute(:executable_path, 'noising/noising.jar')
algorithm2.output = DivaServiceApi.available_output_types[0]
algorithm2.language = DivaServiceApi.available_languages[0]
algorithm2.update_attribute(:environment, 'java:8')
algorithm2.update_attribute(:creation_status, :review)
algorithm2.save!

# InputParameters
##TODO add parameters

############
#Algorithm 3
############
algorithm3 = user.algorithms.create!(name: 'Dummy algorithm 99', namespace: 'diva', description: 'Doesn\'t work, just for testing', creation_status: :empty)
algorithm3.additional_information_with('author').value = 'DIVA'
algorithm3.additional_information_with('email').value = 'dev@diva.unifr.ch'
algorithm3.additional_information_with('website').value = 'http://www.diva.unifr.ch'
algorithm3.update_attribute(:zip_file, File.open(File.join(Rails.root, 'dummy.zip')))
algorithm3.update_attribute(:executable_path, 'empty')
algorithm3.output = DivaServiceApi.available_output_types[0]
algorithm3.language = DivaServiceApi.available_languages[0]
algorithm3.update_attribute(:environment, 'ubuntu:15.10')
algorithm3.update_attribute(:creation_status, :review)
algorithm3.save!

# InputParameters
input_parameter1 = algorithm3.input_parameters.create!(input_type: 'highlighter')
input_parameter1.field_with('type').value = 'circle'

input_parameter2 = algorithm3.input_parameters.create!(input_type: 'text')
input_parameter2.field_with('name').value = 'bananaPhone'
input_parameter2.field_with('description').value = 'Idk, just some fancy variable name'
input_parameter2.field_with('options').field_with('required').value = true
input_parameter2.field_with('options').field_with('min').value = 1
input_parameter2.field_with('options').field_with('max').value = 100
input_parameter2.field_with('options').field_with('default').value = 'ring ring'

input_parameter3 = algorithm3.input_parameters.create!(input_type: 'inputImage')

input_parameter4 = algorithm3.input_parameters.create!(input_type: 'outputImage')

input_parameter5 = algorithm3.input_parameters.create!(input_type: 'number')
input_parameter5.field_with('name').value = 'minBlockWidth'
input_parameter5.field_with('description').value = 'Minimal block width'
input_parameter5.field_with('options').field_with('required').value = true
input_parameter5.field_with('options').field_with('min').value = 1
input_parameter5.field_with('options').field_with('max').value = 100
input_parameter5.field_with('options').field_with('steps').value = 10
input_parameter5.field_with('options').field_with('default').value = 50

input_parameter6 = algorithm3.input_parameters.create!(input_type: 'text')
input_parameter6.field_with('name').value = 'searchText'
input_parameter6.field_with('description').value = 'Text to seach for'
input_parameter6.field_with('options').field_with('required').value = true
input_parameter6.field_with('options').field_with('min').value = 1
input_parameter6.field_with('options').field_with('max').value = 1000
input_parameter6.field_with('options').field_with('default').value = 'Hello World'

input_parameter7 = algorithm3.input_parameters.create!(input_type: 'select')
input_parameter7.field_with('name').value = 'algorithmVersion'
input_parameter7.field_with('description').value = 'What version of the algorithm should be used'
input_parameter7.field_with('options').field_with('required').value = true
input_parameter7.field_with('options').field_with('values').value = ['v1', 'v2', 'v3', 'legacy']
input_parameter7.field_with('options').field_with('default').value = 0

input_parameter8 = algorithm3.input_parameters.create!(input_type: 'highlighter')
input_parameter8.field_with('type').value = 'circle'

input_parameter9 = algorithm3.input_parameters.create!(input_type: 'inputImage')
