class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:recover, :show, :edit, :update, :destroy, :publish]
  before_action :algorithm_finished_wizard!, only:  [:show, :edit, :update]
  before_action :algorithm_is_published, only: [:edit, :update]
  before_action :update_status_from_diva, only: [:index, :show]
  respond_to :html

  def status
    set_algorithm
    render :json => { status: @algorithm.status, status_message: @algorithm.status_message }
  end

  def copy #XXX DEV only
    set_algorithm
    @algorithm.update_version
    redirect_to algorithms_path
  end

  def recover
    unless @algorithm.validation_error? || @algorithm.connection_error? || @algorithm.error?
      flash[:notice] = "Cannot recover from valid status"
      redirect_to algorithms_path(@algorithm)
    end
    @algorithm.update_attributes(status: :review)
    flash[:notice] = @algorithm.status_message
    redirect_to algorithm_algorithm_wizard_path(@algorithm, :review)
  end

  def index
    @algorithms = current_user.algorithms.where(next: nil).paginate(page: params[:page], per_page: 15)
  end

  def show
  end

  def edit
    render view(params[:step])
  end

  def update
    @algorithm.assign_attributes(algorithm_params(params[:step]))
    changed = @algorithm.anything_changed?
    if @algorithm.save
      @algorithm.set_status(:unpublished_changes, 'There are unpublished changes.') if changed
      redirect_to algorithm_path(@algorithm)
    else
      render view(params[:step])
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

  def publish
    unless @algorithm.review? || @algorithm.unpublished_changes?
      flash[:notice] = "Algorithm not yet ready for publishing"
      redirect_to algorithms_path(@algorithm)
    end
    @algorithm.set_status(:validating, 'Informations are currently validated.')
    ValidateAlgorithmJob.perform_later(@algorithm.id)
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:id])
  end

  def algorithm_params(step)
    params.require(:algorithm).permit(permitted_params(step))
  end

  def algorithm_finished_wizard!
    unless @algorithm.finished_wizard?
      flash[:notice] = "Please finish the wizard first"
      redirect_to algorithm_algorithm_wizard_path(@algorithm, @algorithm.status)
    end
  end

  def view(step)
    case step.to_sym
    when :informations
      'algorithms/informations'
    when :parameters
      'algorithms/parameters'
    when :parameters_details
      'algorithms/parameters_details'
    when :upload
      'algorithms/upload'
    end
  end

  def algorithm_is_published
    unless @algorithm.status == 'published' || @algorithm.status == 'unpublished_changes'
      flash[:notice] = "First publish your algorithm"
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
