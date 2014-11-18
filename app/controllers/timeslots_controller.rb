class TimeslotsController < ApplicationController
  include Scheduling
  require 'date'

  def get_weeks_timeslots(dt_string)
    date = DateTime.iso8601(dt_string)
    timeslots = []
    
    for i in 1..7
      ts = Timeslot.where(:date => date.to_date)
      timeslots.push(ts)
      date = date + 1    
    end

    return timeslots
  end

  def get_todays_timeslots
    today = Date.today
    @timeslots = Timeslot.find_by(:date => today)
  end

  def index
    if params[:weekStarting] != nil
      @timeslots = get_weeks_timeslots(params[:weekStarting])
      return
    end

    if params[:date] != nil
      @timeslots = Timeslot.where(:date => params[:date])
    else
      @timeslots = Timeslot.all
    end
  end

	# GET /visualisations/1
  # GET /visualisations/1.json
  def show
    @timeslot = Timeslot.find_by_id(params[:id])
  end

  # GET /visualisations/new
  def new
    @timeslot = Timeslot.new
  end

  # GET /visualisations/1/edit
  def edit
  end

  # POST /visualisations
  # POST /visualisations.json
  def create
    pars = timeslot_params
    @timeslot = Timeslot.new(pars)

    respond_to do |format|
      if @timeslot.save
        format.html { redirect_to @timeslot, notice: 'timeslot was successfully created.' }
        format.json { render :show, status: :created, location: @timeslot }
      else
        format.html { render :new }
        format.json { render json: @timeslot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /timeslots/1
  # PATCH/PUT /timeslots/1.json
  def update
    respond_to do |format|
      if @timeslot.update(timeslot_params)
        format.html { redirect_to @timeslot, notice: 'timeslot was successfully updated.' }
        format.json { render :show, status: :ok, location: @timeslot }
      else
        format.html { render :edit }
        format.json { render json: @timeslot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timeslots/1
  # DELETE /timeslots/1.json
  def destroy
    t = Timeslot.find_by_id(params[:id])
    t.destroy if t != nil

    respond_to do |format|
      format.html { redirect_to timeslots_url, notice: 'Timeslot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def timeslot_params
      params[:timeslot].permit(:start_time, :end_time, :date)
    end

  def test
    @test = get_a_default_programme
  end
end
