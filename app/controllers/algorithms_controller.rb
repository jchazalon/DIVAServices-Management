class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:show, :destroy]
  respond_to :html

  def index
    @algorithms = current_user.algorithms
  end

  def show
  end

  def new
    @algorithm = current_user.algorithms.new
    @algorithm.build_algorithm_info
    @algorithm.input_parameters.build

    #@algorithm.input_parameters.create!(input_type: 'select')
    # @algorithm.input_parameters.build
    #@input_parameter = InputParameter.create!(algorithm: Algorithm.first, input_type: 'select')
  end

  def create
    @algorithm = current_user.algorithms.new(algorithm_params)
    if @algorithm.save!
      redirect_to algorithms_path
    else
      render :new
    end
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:id])
  end

  def algorithm_params
    params.require(:algorithm).permit!
  end

end
