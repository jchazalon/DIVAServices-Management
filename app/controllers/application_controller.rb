class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  protected

  def permitted_params(step)
    case step.to_sym
    when :informations
      [:name, :description, fields_attributes: [:id, :value]]
    when :parameters
      [:output, input_parameters_attributes: [:id, :input_type, :_destroy]]
    when :parameters_details
      field_attributes_base = [:id, :value]
      fields = []
      (1..7).each do
        fields = field_attributes_base + [fields_attributes: fields]
      end
      [input_parameters_attributes: [:id, fields_attributes: fields]]
    when :upload
      [:language, :environment, :zip_file, :executable_path]
    end
  end
end
