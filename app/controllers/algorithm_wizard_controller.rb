##
# Guides the user through the algorithm creation process with the help of a wizard.
# Uses a gem called {wicked}[https://github.com/schneems/wicked] for the wizard.
class AlgorithmWizardController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :diva_service_online!
  before_action :set_algorithm, only: [:show, :update]
  before_action :algorithm_not_finished_yet!, only: [:show, :update]

  steps *Algorithm.wizard_steps

  ##
  # Render views/algorithm_wizard/terms.html.
  def terms
  end

  ##
  # Renders the current view of the wizard and performes some initial actions if necessary.
  def show
    case step
    when :parameters
      # Create an initial input parameter if there is none
      @algorithm.input_parameters.build if @algorithm.input_parameters.empty?
    when :parameters_details
      # Possibly skip a step if there are no parameters used
      if @algorithm.input_parameters.empty?
        if @algorithm.upload?
          jump_to :parameters
        else
          flash[:notice] = "Skipped step 3 due to no input parameters set"
          skip_step
        end
      end
    end
    # Update the step of the algorithm.
    @algorithm.update_attribute(:status, step.to_sym) if steps.include?(step)
    render_wizard
  end

  ##
  # Creates a new algorithms with the status _empty_ and redirects to the wizard.
  def create
    @algorithm = current_user.algorithms.create!(status: :empty, user: current_user)
    redirect_to wizard_path(steps.first, algorithm_id: @algorithm.id)
  end

  ##
  # Saves the changes from each step to the algorithm. Note that all changes must be permitted in the AlgorithmWizardController#algorithm_params(step) method!
  def update
    @algorithm.assign_attributes(algorithm_params(step))
    render_wizard @algorithm
  end

  ##
  # Initializes the validation and exits the wizard.
  def finish_wizard_path
    @algorithm.set_status(:validating, 'Information are currently validated.')
    ValidateAlgorithmJob.perform_later(@algorithm.id)
    algorithms_path
  end

  private

  ##
  # Gets the algorithm from the URL params.
  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end

  ##
  # Redirects if the algorithm already passed the wizard.
  def algorithm_not_finished_yet!
    if @algorithm.finished_wizard?
      flash[:notice] = "The algorithm '#{@algorithm.name}' is already finished! The wizard can only be accessed during creation. Use the edit routes to update an exising algorithm."
      redirect_to algorithms_path
    end
  end

  ##
  # Permits the params of the current step. For more details see ApplicationController#permitted_params(step).
  def algorithm_params(step)
    params.require(:algorithm).permit(permitted_params(step))
  end

  ##
  # Redirects if the DIVAServices is not reachable.
  def diva_service_online!
    unless DivaServicesApi.is_online?
      flash[:error] = "DIVAServices is currently not reachable. Please stand by until we are able to reconnect."
      redirect_to algorithms_path
    end
  end
end
