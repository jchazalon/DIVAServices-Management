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
algorithm = user.algorithms.create!(name: 'Dummy Algorithm', namespace: 'diva', description: 'This is a dummy algorithm', creation_status: :done)
algorithm.additional_information_with('author').value = 'DIVA'
algorithm.additional_information_with('email').value = 'dev@diva.unifr.ch'
algorithm.additional_information_with('website').value = 'www.unifr.ch'

algorithm.output = DivaServiceApi.available_output_types[1]
algorithm.language = DivaServiceApi.available_languages[1]
algorithm.save!

# InputParameter
p '--------------------'
p 'number'
 input_parameter1 = algorithm.input_parameters.create!(algorithm: algorithm, input_type: 'number')
p '--------------------'
p 'text'
input_parameter2 = algorithm.input_parameters.create!(algorithm: algorithm, input_type: 'text')
p '--------------------'
p 'select'
input_parameter3 = algorithm.input_parameters.create!(algorithm: algorithm, input_type: 'select')
p '--------------------'
p 'highlighter'
input_parameter4 = algorithm.input_parameters.create!(algorithm: algorithm, input_type: 'highlighter')
