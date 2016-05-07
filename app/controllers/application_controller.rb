class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  protected

  def permitted_params(step)
    case step.to_sym
    when :informations
      [general_fields_attributes: [:id, :value]]
    when :parameters
      [output_fields_attributes: [:id, :value], input_parameters_attributes: [:id, :input_type, :_destroy]]
    when :parameters_details
      field_attributes_base = [:id, :value]
      fields = []
      (1..7).each do
        fields = field_attributes_base + [fields_attributes: fields]
      end
      [input_parameters_attributes: [:id, fields_attributes: fields]]
    when :upload
      [:zip_file, method_fields_attributes: [:id, :value]]
    end
  end
end
