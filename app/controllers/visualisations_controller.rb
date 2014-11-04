class VisualisationsController < ApplicationController
  before_action :set_visualisation, only: [:show, :edit, :update, :destroy]

  # PATCH /visualisations/:visid/approve
  def approve
    if current_user.isAdmin
       v = Visualisation.find(params[:visid])
       v.approved = true
       v.save!
    else 
       redirect_to '/visualisations'
    end
  end
  
  # GET /visualisations
  # GET /visualisations.json
  def index
    if params[:needsModerating]
      @visualisations = Visualisation.where(approved:false)
    else
      @visualisations = Visualisation.all
    end
  end

  # GET /visualisations/1
  # GET /visualisations/1.json
  def show
    @visualisation = Visualisation.find(params[:id])
  end

  # GET /visualisations/new
  def new
    @visualisation = Visualisation.new
  end

  # GET /visualisations/1/edit
  def edit
  end

  # POST /visualisations
  # POST /visualisations.json
  def create
    p = visualisation_params
    puts p
    @visualisation = Visualisation.new(p)
    @visualisation.approved = true
    #current_user.visualisations << @visualisation
    respond_to do |format|
      if @visualisation.save
        format.html { redirect_to @visualisation, notice: 'Visualisation was successfully created.' }
        format.json { render :show, status: :created, location: @visualisation }
      else
        format.html { render :new }
        format.json { render json: @visualisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visualisations/1
  # PATCH/PUT /visualisations/1.json
  def update
    respond_to do |format|
      if @visualisation.update(visualisation_params)
        format.html { redirect_to @visualisation, notice: 'Visualisation was successfully updated.' }
        format.json { render :show, status: :ok, location: @visualisation }
      else
        format.html { render :edit }
        format.json { render json: @visualisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visualisations/1
  # DELETE /visualisations/1.json
  def destroy
    @visualisation.destroy
    respond_to do |format|
      format.html { redirect_to visualisations_url, notice: 'Visualisation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visualisation
      @visualisation = Visualisation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def visualisation_params
      params[:visualisation].permit(:name, :link, :description, :notes, :author_info, :content_type, :file, :approved)
    end
end
