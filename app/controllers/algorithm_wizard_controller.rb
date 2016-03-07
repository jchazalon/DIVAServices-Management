class AlgorithmWizardController < ApplicationController
  include Wicked::Wizard
  before_action :set_algorithm, only: [:show, :update]

  steps *Algorithm.steps

  def show
    case step
    when :informations
      @algorithm.update_attribute(:creation_status, step)
    when :parameters
      @algorithm.update_attribute(:creation_status, step)
      @algorithm.input_parameters.build if @algorithm.input_parameters.empty?
    when :parameters_details
      @algorithm.update_attribute(:creation_status, step)
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
      @algorithm.assign_attributes(algorithm_params_step1)
    when :parameters
      @algorithm.assign_attributes(algorithm_params_step2)
    when :parameters_details
      @algorithm.assign_attributes(algorithm_params_step3)
    when :upload
      @algorithm.assign_attributes(algorithm_params_step4)
    end
    render_wizard @algorithm
  end

  def finish_wizard_path
    @algorithm.update_attribute(:creation_status, :done)
    algorithms_path
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end

  def algorithm_params_step1
    params.require(:algorithm).permit(:name, :namespace, :description, fields_attributes: [:id, :value])
  end

  def algorithm_params_step2
    params.require(:algorithm).permit(:output, input_parameters_attributes: [:id, :input_type, :_destroy])
  end

  # Accepts up to 7 level deep nested fields
  def algorithm_params_step3
    field_attributes_base = [:id, :value]
    fields = []
    (1..7).each do
      fields = field_attributes_base + [fields_attributes: fields]
    end
    params.require(:algorithm).permit(input_parameters_attributes: [:id, fields_attributes: fields])
  end

  def algorithm_params_step4
    params.require(:algorithm).permit(:language, :zip_file)
  end
end
