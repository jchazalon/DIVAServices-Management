class InputParametersController < ApplicationController
  before_action :set_algorithm, only: :sort
  respond_to :html

  def sort
    params[:sorted_input_parameters].each_with_index do |id, pos|
     input_parameter = @algorithm.input_parameters.find(id)
     input_parameter.position = pos
     input_parameter.save!
   end
   render nothing: true
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end
end
