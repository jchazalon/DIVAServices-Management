class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:recover, :show, :edit, :update, :destroy, :publish]
  before_action :algorithm_published!, only: [:show, :edit, :update]
  before_action :update_status_from_diva, only: :index
  before_action :needs_recover, only: :recover
  respond_to :html

  def status
    set_algorithm
    update_status(@algorithm) if @algorithm.publication_pending?
    render :json => { status: @algorithm.status, status_message: @algorithm.status_message }
  end

  #XXX DEV only
  def copy
    set_algorithm
    @algorithm.update_version
    redirect_to algorithms_path
  end

  def recover
    @algorithm.update_attributes(status: :review)
    flash[:notice] = "Latest status: #{@algorithm.status_message}"
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
      @algorithm.set_status(:unpublished_changes, 'There are unpublished changes.') if changed #NOTE Because only published algorithms can be edited
      redirect_to algorithm_path(@algorithm)
    else
      render view(params[:step])
    end
  end

  def destroy
    if @algorithm.finished_wizard?
      if DivaServicesApi::Algorithm.by_id(@algorithm.diva_id).delete && @algorithm.destroy
        flash[:notice] = "Deleted algorithm from DIVAService"
      end
    elsif @algorithm.destroy
      flash[:notice] = "Deleted algorithm"
    end
    redirect_to algorithms_path
  end

  def publish
    unless @algorithm.review? || @algorithm.unpublished_changes?
      flash[:notice] = "Algorithm not yet ready for publishing"
      redirect_to algorithms_path
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

  def algorithm_published!
    unless @algorithm.finished_wizard? || @algorithm.published? || @algorithm.unpublished_changes?
      flash[:notice] = "First publish your algorithm"
      redirect_to algorithms_path
    end
  end

  def needs_recover
    unless @algorithm.validation_error? || @algorithm.connection_error? || @algorithm.error?
      flash[:notice] = "Cannot recover from valid status"
      redirect_to algorithms_path
    end
  end

  def update_status_from_diva
    algorithms = current_user.algorithms.where.not(status: [0,1,2,3,4,5])
    algorithms.each do |algorithm|
      update_status(algorithm) if algorithm.publication_pending?
    end
  end

  def update_status(algorithm)
    diva_algorithm = DivaServicesApi::Algorithm.by_id(algorithm.diva_id)
    algorithm.set_status(diva_algorithm.status_code, diva_algorithm.status_message) if diva_algorithm.status_code != Algorithm.statuses[algorithm.status]
  end
end
