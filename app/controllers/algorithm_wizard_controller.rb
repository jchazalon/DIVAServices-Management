class AlgorithmWizardController < ApplicationController
  include Wicked::Wizard
  before_action :algorithm_not_finished_yet!, only: [:show, :update]
  before_action :set_algorithm, only: [:show, :update]

  steps *Algorithm.steps

  def show
    case step
    when :parameters
      @algorithm.input_parameters.build if @algorithm.input_parameters.empty?
    when :parameters_details
      if @algorithm.input_parameters.empty?
        if @algorithm.creation_status == 'upload'
          jump_to :parameters
        else
          flash[:notice] = "Skipped step 3 due to no input parameters set"
          skip_step
        end
      end
    end
    @algorithm.update_attribute(:creation_status, step.to_sym) if steps.include?(step)
    render_wizard
  end

  def create
    @algorithm = current_user.algorithms.create!(creation_status: :empty)
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

    # Create Dockerfile
    directory_name = "public/uploads/algorithm/zip_file/#{@algorithm.id}/docker/"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    File.open(File.join("public/uploads/algorithm/zip_file/#{@algorithm.id}/docker/", 'Dockerfile'), 'w+') do |file|
      file.write "FROM ubuntu\n" +
        "MAINTAINER diva@unifr.ch\n" +
        "RUN apt-get update\n" +
  		  "COPY . /data/algorithm/"
    end

    # Unpack zip
    Zip::File.open("public/uploads/algorithm/zip_file/#{@algorithm.id}/dummy.zip") do |zipfile|
      zipfile.each do |file|
        f_path=File.join("public/uploads/algorithm/zip_file/#{@algorithm.id}/docker/", file.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zipfile.extract(file, f_path) unless File.exist?(f_path)
      end
    end

    p 'start'
    p `ls`
    p `cd public/uploads/algorithm/zip_file/#{@algorithm.id}/docker/ && tar -zcvf docker.tar * && cd ../../../../../../`
    p `ls`

    p Docker::Image.build_from_tar(File.open(File.join("public/uploads/algorithm/zip_file/#{@algorithm.id}/docker/", 'docker.tar'), 'r'))

    #CreateDockerJob.perform_later(@algorithm.id)
    algorithms_path
  end

  private

  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:algorithm_id])
  end

  def algorithm_not_finished_yet!
    @algorithms = set_algorithm
    if @algorithm.creation_status == :done
      flash[:notice] = "The algorithm '#{@algorithm.name}' is already finished!"
      redirect_to algorithms_path
    end
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
    params.require(:algorithm).permit(:language, :zip_file, :executable_path)
  end
end
