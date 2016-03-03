class AlgorithmsController < ApplicationController

  def index
    @algorithms = current_user.algorithms
  end  

end
