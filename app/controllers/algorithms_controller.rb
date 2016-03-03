class AlgorithmsController < ApplicationController

  def index
    @algorithms = current_user.algorithms
  end

  def new
    @algorithm = current_user.algorithms.new
    @algorithm.build_algorithm_info
    @algorithm.input_parameters.build
    @algorithm.input_parameters.build
  end

end
