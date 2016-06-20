##
# Responsible to enable CRUD actions on _algorithms_. Additionally provides methods to revert to a previous version, recover from errors and publish to the DIVAServices.
# Uses a gem calles {will_paginate}[https://github.com/mislav/will_paginate] to allow pagination.
class AlgorithmsController < ApplicationController
  require 'will_paginate/array'
  before_action :authenticate_user!
  before_action :set_algorithm, except: :index
  before_action :algorithm_published!, only: [:exceptions, :show, :edit, :update]
  before_action :algorithm_has_unpublished_changes!, only: :revert
  before_action :can_recover, only: :recover
  respond_to :html

  ##
  # Fetches the status of the _algorithm_ and returns it as json.
  # Normally the status is simply read from the _algorithm_. However, if there is a publication pending, the status is updated from the DIVAServices.
  def status
    render :json => { status: @algorithm.status(@algorithm.publication_pending?), status_message: @algorithm.status_message }
  end

  ##
  # Discards all unpublished changes and reverts to the last version of the _algorithm_.
  def revert
    predecessor = Algorithm.where(next: @algorithm).first
    if predecessor
      # Exchange current version with copy of previous version ;)
      new_algorithm = @algorithm.revert_changes(predecessor)
      flash[:notice] = "Algorithm has been reverted to the previous version"
      redirect_to algorithm_path(new_algorithm)
    else
      flash[:notice] = "Could not find previous version"
      redirect_to algorithms_path
    end
  end

  ##
  # Recover from an error by going back to the last edit status and display the received exception/error.
  def recover
    flash[:notice] = "Latest error: #{@algorithm.status_message}"
    # Either go to the wizard (_review_) or to the edit page (_unpublished changes_)
    if @algorithm.already_published?
      @algorithm.set_status(:unpublished_changes)
      redirect_to algorithm_path(@algorithm)
    else
      @algorithm.set_status(:review)
      redirect_to algorithm_algorithm_wizard_path(@algorithm, :review)
    end
  end

  ##
  # Render views/algorithms/exceptions.html and list all exceptions.
  def exceptions
    @exceptions = DivaServicesApi::Algorithm.by_id(@algorithm.diva_id).exceptions
  end

  ##
  # List all owned _algorithms_ and sort them by published and not published.
  # If the current user is an administrator, list all _algorithms_.
  def index
    if current_user.admin?
      algorithms = Algorithm.where(next: nil).order(:updated_at)
    else
      algorithms = current_user.algorithms.where(next: nil).order(:updated_at)
    end
    @algorithms = algorithms.sort do |a,b|
      if a.already_published? && b.already_published? || !a.already_published? && !b.already_published?
        b.updated_at <=> a.updated_at
      else
        a.already_published? && !b.already_published? ? -1 : 1
      end
    end.paginate(page: params[:page], per_page: 15)
  end

  ##
  # Renders views/algorithms/show.html.
  def show
  end

  ##
  # Renders the edit view that was requested via the :step parameter.
  # Note that the :step parameter is not the status here, it is simply used to address the correct view!
  # The selection of the correct view is performed in AlgorithmsController#view(step).
  def edit
    render view(params[:step])
  end

  ##
  # Save the changes from the edit view.
  def update
    @algorithm.assign_attributes(algorithm_params(params[:step]))
    changed = @algorithm.anything_changed?
    if @algorithm.save
      # Only published algorithms can be edited
      @algorithm.set_status(:unpublished_changes, 'There are unpublished changes.') if changed
      redirect_to algorithm_path(@algorithm)
    else
      # In case of error return to the edit view
      render view(params[:step])
    end
  end

  ##
  # Remove the _algorithm_ from DIVAServices and DIVAServices-Algorithm.
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

  ##
  # Initializes the publication process if possible.
  def publish
    unless @algorithm.review? || @algorithm.unpublished_changes?
      flash[:notice] = "Algorithm not yet ready for publishing"
      redirect_to algorithms_path
    else
      @algorithm.set_status(:validating, 'Information are currently validated.')
      ValidateAlgorithmJob.perform_later(@algorithm.id)
      redirect_to algorithms_path
    end
  end

  private

  ##
  # Gets the _algorithm_ from the URL params.
  def set_algorithm
    @algorithm = current_user.algorithms.find(params[:id])
  end

  ##
  # Permits the params of the current edit view. For more details see ApplicationController#permitted_params(step).
  def algorithm_params(step)
    params.require(:algorithm).permit(permitted_params(step))
  end

  ##
  # Matches an symbol (we used the steps from the wizard) to a edit view.
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

  ##
  # Redirects if the _algorithm_ is already published.
  def algorithm_published!
    unless @algorithm.finished_wizard? || @algorithm.published? || @algorithm.unpublished_changes?
      flash[:notice] = "First publish your algorithm"
      redirect_to algorithms_path
    end
  end

  ##
  # Redirects if the _algorithm_ has unpublished changes.
  def algorithm_has_unpublished_changes!
    unless @algorithm.unpublished_changes?
      flash[:notice] = "You have no unpublished changes"
      redirect_to algorithms_path
    end
  end

  ##
  # Redirects if the _algorithm_ cannot be recovered in its current state.
  def can_recover
    unless @algorithm.validation_error? || @algorithm.connection_error? || @algorithm.error?
      flash[:notice] = "Cannot recover from valid status"
      redirect_to algorithms_path
    end
  end
end
