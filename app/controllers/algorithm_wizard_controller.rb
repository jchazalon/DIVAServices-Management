class AlgorithmWizardController < ApplicationController
  include Wicked::Wizard
  before_action :diva_service_online!
  before_action :set_algorithm, only: [:show, :update]
  before_action :algorithm_not_finished_yet!, only: [:show, :update]

  steps *Algorithm.wizard_steps

  def terms
  end

  def show
    case step
    when :parameters
      @algorithm.input_parameters.build if @algorithm.input_parameters.empty?
    when :parameters_details
      if @algorithm.input_parameters.empty? #XXX is that even allowed?
        if @algorithm.upload?
          jump_to :parameters
        else
          flash[:notice] = "Skipped step 3 due to no input parameters set"
          skip_step
        end
      end
    end
    @algorithm.update_attribute(:status, step.to_sym) if steps.include?(step)
    render_wizard
  end

  def create
    @algorithm = current_user.algorithms.create!(status: :empty)
    redirect_to wizard_path(steps.first, algorithm_id: @algorithm.id)
  end

  def update
    @algorithm.assign_attributes(algorithm_params(step))
    render_wizard @algorithm
  end

  def finish_wizard_path
    @algorithm.set_status(:validating, 'Informations are currently validated.')
    ValidateAlgorithmJob.perform_later(@algorithm.id)
    algorithms_path
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end

  def algorithm_not_finished_yet!
    if @algorithm.finished_wizard?
      flash[:notice] = "The algorithm '#{@algorithm.name}' is already finished! The wizard can only be accessed during creation. Use the edit routes to update an exising algorithm."
      redirect_to algorithms_path
    end
  end

  def algorithm_params(step)
    params.require(:algorithm).permit(permitted_params(step))
  end

  def diva_service_online!
    unless DivaServicesApi.is_online?
      flash[:error] = "DIVAService is currently not reachable. Please stand by until we are able to reconnect."
      redirect_to algorithms_path
    end
  end
end
