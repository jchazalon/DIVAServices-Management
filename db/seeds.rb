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

user = User.create!(email: 'dev@diva.unifr.ch', password: '12345678')


#Algorithm
algorithm = user.algorithms.create!(name: 'Dummy Algorithm', namespace: 'diva', description: 'This is a dummy algorithm', creation_status: :empty)
algorithm.additional_information_with('author').value = 'DIVA'
algorithm.additional_information_with('email').value = 'dev@diva.unifr.ch'
algorithm.additional_information_with('website').value = 'www.unifr.ch'
algorithm.update_attribute(:zip_file, File.open(File.join(Rails.root, 'dummy.zip')))
algorithm.update_attribute(:executable_path, 'empty')
algorithm.output = DivaServiceApi.available_output_types[1]
algorithm.language = DivaServiceApi.available_languages[1]
algorithm.update_attribute(:creation_status, :done)
algorithm.save!

# InputParameter
input_parameter1 = algorithm.input_parameters.create!(input_type: 'number')
input_parameter1.field_with('name').value = 'minBlockWidth'
input_parameter1.field_with('description').value = 'Minimal block width'
input_parameter1.field_with('options').field_with('required').value = true
input_parameter1.field_with('options').field_with('min').value = 1
input_parameter1.field_with('options').field_with('max').value = 100
input_parameter1.field_with('options').field_with('steps').value = 10
input_parameter1.field_with('options').field_with('default').value = 50


input_parameter2 = algorithm.input_parameters.create!(input_type: 'text')
input_parameter2.field_with('name').value = 'bananaPhone'
input_parameter2.field_with('description').value = 'Idk, just some fancy variable name'
input_parameter2.field_with('options').field_with('required').value = true
input_parameter2.field_with('options').field_with('min').value = 1
input_parameter2.field_with('options').field_with('max').value = 100
input_parameter2.field_with('options').field_with('default').value = 'ring ring'


input_parameter3 = algorithm.input_parameters.create!(input_type: 'select')
input_parameter3.field_with('name').value = 'algorithmVersion'
input_parameter3.field_with('description').value = 'What version of the algorithm should be used'
input_parameter3.field_with('options').field_with('required').value = true
input_parameter3.field_with('options').field_with('values').value = ['v1', 'v2', 'v3', 'legacy']
input_parameter3.field_with('options').field_with('default').value = 0


input_parameter4 = algorithm.input_parameters.create!(input_type: 'highlighter')
input_parameter4.field_with('type').value = 'circle'


input_parameter5 = algorithm.input_parameters.create!(input_type: 'inputImage')
