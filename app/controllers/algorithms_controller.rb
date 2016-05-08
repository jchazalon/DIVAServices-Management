class AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: [:recover, :show, :edit, :update, :destroy, :publish]
  before_action :algorithm_published!, only: [:show, :edit, :update]
  before_action :update_status_from_diva, only: :index
  before_action :needs_recover, only: :recover
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
      if DivaServiceApi.delete_algorithm(@algorithm) && @algorithm.destroy
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
    if DivaServiceApi.is_online?
      algorithms = current_user.algorithms.where.not(status: [0,1,2,3,4,5])
      algorithms.each do |algorithm|
       if algorithm.publication_pending?
         response = DivaServiceApi.status(@algorithm.diva_id)
         if !response.empty? && response['statusCode'] != Algorithm.statuses[@algorithm.status]
           @algorithm.set_status(response['statusCode'], response['statusMessage'])
         end
       end
      end
    else
      flash[:error] = "DIVAService currently not reachable"
    end
  end
end
