class VisualisationsController < ApplicationController
  before_action :set_visualisation, only: [:show, :edit, :update, :destroy]

  # GET /visualisations/:visid/schedule
  def add_to_schedule
    #TODO: add to current schedule array
  end

  # PATCH /visualisations/:visid/approve
  def approve
    if current_user.isAdmin
      v = Visualisation.find_by_id(params[:visid])
      unless v == nil
        v.approved = true
        v.save!
      end
    else 
       redirect_to '/visualisations'
    end
  end

  
  # DELETE /visualisations/:visid/reject
  def reject
    if current_user.isAdmin
      v = Visualisation.find_by_id(params[:visid])
      unless v == nil
        v.delete
      end
    end

    redirect_to '/visualisations'
  end
  
  # GET /visualisations
  # GET /visualisations.json
  def index
    @expandAuthor = params[:expandAuthor]
    @visualisations = Visualisation.all

    if params[:userid] == nil
      if params[:newest] != nil

      @visualisations = get_newest_n(params[:newest])
      end

      if params[:needsModeration] != nil
        @visualisations = @visualisations.select{ |vis| vis.approved == false }
      else
        @visualisations = @visualisations.select{ |vis| vis.approved == true }
      end
      
    else
      #want visualisations of a particular user
      u = User.find_by_id(params[:userid])
      if u == nil
        return "no such user"
      end

      if params[:needsModeration] != nil
        @visualisations = u.visualisations.approved(false)
      else
        @visualisations = u.visualisations.approved(true)
      end
    end

    
  end

  def get_newest_n(n)
    return Visualisation.order(created_at: :desc).take(n)
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
