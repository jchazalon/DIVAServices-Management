class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:show, :update, :destroy]
  before_action :algorithm_finished_wizard!, only: :show
  respond_to :html

  #XXX Dev only
  def dev_unpublish
    algorithm = current_user.algorithms.find(params[:id])
    algorithm.update_attributes(creation_status: :review)
    redirect_to algorithms_path
  end

  def index
    @algorithms = current_user.algorithms.where.not(creation_status: [1,2,3,4,5])
    @unfinished_algorithms = current_user.algorithms.where(creation_status: [1,2,3,4,5])
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

  def algorithm_finished_wizard!
    unless @algorithm.finished_wizard?
      flash[:notice] = "Please finish the wizard first"
      redirect_to algorithm_algorithm_wizard_path(@algorithm, @algorithm.creation_status)
    end
  end

end
