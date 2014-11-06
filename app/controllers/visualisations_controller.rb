class VisualisationsController < ApplicationController

  # GET /visualisations/:visid
  def show
    @visualisation = Visualisation.find(params[:visid])  
  end

  # GET /visualisations
  def index
    @visualisations = Visualisation.all
  end    

  # DELETE /visualisations/:visid
  def delete
    user = current_user
    if !user.isAdmin
      redirect_to :back, :alert => "You are not an admin!"
    else
      Visualisation.find(params[:visid]).delete
    end
  end
end
