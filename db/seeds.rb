User.delete_all
Algorithm.delete_all

user = User.create!(email: 'dev@diva.unifr.ch', password: '12345678')


algorithm = user.algorithms.create!(name: 'My Algotithm', namespace: 'diva', description: 'This is my fist algorithm')
algorithm.algorithm_info = AlgorithmInfo.create!(algorithm: algorithm)# author: 'Me', email: 'dev@diva.unifr.ch', website: 'diuf.unifr.ch/diva')
input_parameter1 = algorithm.input_parameters.create!(algorithm: algorithm, input_type: 'number')
input_parameter1.fields.create!(type: 'StringField', name: 'name')
input_parameter1.fields.create!(type: 'StringField', name: 'description')
options = input_parameter1.fields.create!(type: 'ObjectField', name: 'options')
options.fields.create!(type: 'BooleanField', name: 'required')
options.fields.create!(type: 'NumberField', name: 'default')
options.fields.create!(type: 'NumberField', name: 'min')
options.fields.create!(type: 'NumberField', name: 'max')
options.fields.create!(type: 'NumberField', name: 'step')
