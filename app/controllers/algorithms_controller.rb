class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:recover, :show, :update, :destroy]
  before_action :algorithm_finished_wizard!, only: :show
  before_action :can_recover, only: :recover
  before_action :update_status_from_diva, only: [:index, :show]
  respond_to :html

  def copy #XXX DEV only
    set_algorithm
    @algorithm.update_version
    redirect_to algorithms_path
  end

  def recover
    @algorithm.update_attributes(status: :review)
    flash[:notice] = @algorithm.status_message
    redirect_to algorithm_algorithm_wizard_path(@algorithm, :review)
  end

  def index
    @algorithms = current_user.algorithms.where(next: nil).paginate(page: params[:page], per_page: 15)
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
    if @algorithm.finished_wizard?
      if DivaServiceApi.delete_algorithm(@algorithm) && @algorithm.destroy
        flash[:notice] = "Deleted algorithm #{@algorithm.name} from DIVAService"
      else
        flash[:error] = "Could not delete algorithm #{@algorithm.name} from DIVAService"
      end
    elsif @algorithm.destroy
      flash[:notice] = "Deleted algorithm #{@algorithm.name}"
    else
      flash[:error] = "Could not delete algorithm #{@algorithm.name}"
    end
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
      redirect_to algorithm_algorithm_wizard_path(@algorithm, @algorithm.status)
    end
  end

  def can_recover
    unless @algorithm.validation_error? || @algorithm.connection_error? || @algorithm.error?
      flash[:notice] = "Cannot recover from valid status"
      redirect_to algorithms_path(@algorithm)
    end
  end

  def update_status_from_diva
    if DivaServiceApi.is_online?
      algorithms = current_user.algorithms.where.not(status: [0,1,2,3,4,5])
      algorithms.each do |algorithm|
        algorithm.pull_status if algorithm.publication_pending?
      end
    else
      flash[:error] = "DIVAService currently not reachable"
    end
  end

end
