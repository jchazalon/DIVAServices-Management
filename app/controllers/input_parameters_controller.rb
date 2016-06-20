##
# Controller to allow the sorting of the _input parameters_.
class InputParametersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_algorithm, only: :sort
  respond_to :html

  ##
  # Allows the _input parameters_ to be sorted.
  # Expects to receive an array with the _input parameters_ ids sorted in the prefered order.
  def sort
    params[:sorted_input_parameters].each_with_index do |id, pos|
     input_parameter = @algorithm.input_parameters.find(id)
     input_parameter.position = pos
     input_parameter.save!
   end
   render nothing: true
  end

  private

  ##
  # Gets the _algorithm_ from the URL params.
  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end
end
