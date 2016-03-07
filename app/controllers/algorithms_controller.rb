class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:show, :update, :destroy]
  respond_to :html

  def index
    @algorithms = current_user.algorithms.where(creation_status: 5) #TODO fix with symbol
  end

  def show
  end

  def update
    if @algorithm.update(algorithm_params)
      redirect_to algorithms_path
    else
      render :edit
    end
  end

  def destroy
    @algorithm.destroy
    redirect_to algorithms_path
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:id])
  end

  def algorithm_params
    params.require(:algorithm).permit!
  end

end
