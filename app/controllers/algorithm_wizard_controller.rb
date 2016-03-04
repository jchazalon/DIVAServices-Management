class AlgorithmWizardController < ApplicationController
  include Wicked::Wizard
  before_action :set_algorithm, only: [:show, :update]

  steps :informations, :parameters, :parameters_details, :upload

  def show
    case step
    when :informations
      @algorithm.update_attribute(:creation_status, step)
      @algorithm.build_algorithm_info if @algorithm.algorithm_info.nil?
    when :parameters
      @algorithm.update_attribute(:creation_status, step)
      @algorithm.input_parameters.build if @algorithm.input_parameters.size == 0
    when :parameters_details
      @algorithm.update_attribute(:creation_status, step)
      @input_parameters = @algorithm.input_parameters
    when :upload
      @algorithm.update_attribute(:creation_status, step)
    end
    render_wizard
  end

  def create
    @algorithm = current_user.algorithms.create!(creation_status: 'empty')
    redirect_to wizard_path(steps.first, algorithm_id: @algorithm.id)
  end

  def update
    case step
    when :informations
      @algorithm.update!(algorithm_params)
    when :parameters
      @algorithm.update!(algorithm_params)
    when :parameters_details
    when :upload
    end
    render_wizard @algorithm
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end

  def algorithm_params
    params.require(:algorithm).permit!
  end

end
