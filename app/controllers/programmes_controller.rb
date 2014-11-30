class ProgrammesController < ApplicationController

	def index
    if params[:timeslot_id] != nil
		  @programmes = Programme.where(:timeslot_id => :timeslot_id)
    else
      @programmes = Programme.all
    end
	end

	# GET /programmes/1
  # GET /programmes/1.json
  def show
    @programme = Programme.find_by_id(params[:id])
  end

  # GET /programmes/new
  def new
    @programme = Programme.new
  end

  # GET /programmes/1/edit
  def edit
  end

  # POST /programmes
  # POST /programmes.json
  def create
    pars = programme_params
    @programme = Programme.new(pars)

    puts params[:programme][:visualisation_id]
    puts params[:programme][:timeslot_id]

    if (params[:programme][:visualisation_id] == nil or params[:programme][:timeslot_id] == nil)
      @programme.delete
      render :status => :internal_server_error, :text => "Need to supply timeslot and visualisation params."
      return
    end

    v = Visualisation.find_by_id(params[:programme][:visualisation_id])
    if v == nil
      @programme.delete
      render :status => :internal_server_error, :text => "No such visualisation."
      return
    end

    v.programmes << @programme
 
    t = Timeslot.find_by_id(params[:programme][:timeslot_id])
    if t == nil
      @programme.delete
      render :status => :internal_server_error, :text => "No such timeslot."
      return
    end
     
    t.programmes << @programme

    respond_to do |format|
      if @programme.save
        format.html { redirect_to @programme, notice: 'Programme was successfully created.' }
        format.json { render :show, status: :created, location: @programme }
      else
        format.html { render :new }
        format.json { render json: @programme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /programmes/1
  # PATCH/PUT /programmes/1.json
  def update
    respond_to do |format|
      if @programme.update(programme_params)
        format.html { redirect_to @programme, notice: 'Programme was successfully updated.' }
        format.json { render :show, status: :ok, location: @programme }
      else
        format.html { render :edit }
        format.json { render json: @programme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programmes/1
  # DELETE /programmes/1.json
  def destroy
    p = Programme.find_by_id(params[:id])
    p.destroy if p != nil

    respond_to do |format|
      format.html { redirect_to visualisations_url, notice: 'Programme was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def programme_params
      params.require(:programme).permit(:priority, :screens, :visualisation_id, :timeslot_id)
    end
end
