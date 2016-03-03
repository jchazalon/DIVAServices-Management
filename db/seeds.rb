User.delete_all
Algorithm.delete_all

user = User.create!(email: 'dev@diva.unifr.ch', password: '12345678')


#Algorithm
algorithm = user.algorithms.create!(name: 'My Algotithm', namespace: 'diva', description: 'This is my fist algorithm')

#AlgotithmInfo
algorithm.algorithm_info = AlgorithmInfo.create!(algorithm: algorithm, author: 'Me', email: 'dev@diva.unifr.ch', website: 'diuf.unifr.ch/diva')

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
