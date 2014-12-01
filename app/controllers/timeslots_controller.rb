class TimeslotsController < ApplicationController
  include Scheduling
  require 'date'



  # POST /timeslots/copy_from_last_week
  def copy_from_last_week
    current_day = DateTime.iso8601(params[:day])
    last_week_day = current_day - 7

    @new_timeslots = []

    ts_last = Timeslot.where(:date => current_day_.to_date)
    ts_last.each do |ts|
      ts_new = ts.dup
      ts_new.date = current_day.to_date
      #keep start and end time the same
      ts_new.save
      @new_timeslots.push(ts_new)
    end

  end

  # POST /timeslots/copy_last_seven
  def copy_last_seven
    last_week = get_weeks_timeslots(params[:startDay].to_date - 7)
    curent = DateTime.iso8601(params[:startDay])
    @this_week  = [] 

    last_week.each do |day|
      todays_vis = []
      day.each do |timeslot|
        new_timeslot = timeslot.dup
        new_timeslot.date = current
        new_timeslot.save!
        todays_vis.push(new_timeslot)
      end
      @this_week.push(todays_vis)
      current = current + 1
    end
  end

  # used by copy_last_seven
  def get_weeks_timeslots(dt_string)
    dt = DateTime.iso8601(dt_string)
    days = []
    
    for i in 1..7
      ts = Timeslot.where(:date => dt.to_date)
      days.push(ts)
      dt = dt + 1    
    end

    return days
  end

  # utility func
  def get_todays_timeslots
    today = Date.today
    @timeslots = Timeslot.where(:date => today)
  end

  # GET /timeslots
  def index
    if params[:weekStarting] != nil
      @timeslots = get_weeks_timeslots(params[:weekStarting])
      return
    end

    if params[:datetime] != nil
      @timeslots = Timeslot.where(:date => DateTime.iso8601(params[:date]).to_date)
    else
      @timeslots = Timeslot.all
    end
  end

	# GET /timeslots/1
  # GET /timeslots/1.json
  def show
    @timeslot = Timeslot.find_by_id(params[:id])
  end

  # GET /timeslots/new
  def new
    @timeslot = Timeslot.new
  end

  # GET /timeslots/1/edit
  def edit
  end

  # POST /timeslots
  # POST /timeslots.json
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
        generate_schedule(@timeslot)
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

  def visNames
        ['Milan', 'Green', 'Pink', 'Power', 'Test', 'BomWowWow']
      end

      def getVis(min_playtime = Const.SECONDS_IN_UNIT_TIME)
        return Visualisation.create({:name => visNames.sample,
                                     :min_playtime => min_playtime})
      end

  def test
    start_time = DateTime.new(2014, 11, 19, 12, 0, 0).utc
    end_time = DateTime.new(2014, 11, 19, 12, 10, 0).utc

     prog1 = Programme.create({:screens => 2, :priority => 1})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => 2, :priority => 1})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => 2, :priority => 10})
          prog3.visualisation = getVis

    timeslot = Timeslot.create({:start_time => start_time,
                                :end_time => end_time})
    timeslot.programmes << [prog1, prog2, prog3]
    
    generate_schedule(timeslot, 1, 4)

    @test = PlayoutSession.where(start_time: start_time...end_time)
    @start_time = start_time
    @end_time = end_time
    @count = PlayoutSession.count

  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def timeslot_params
      params[:timeslot].permit(:start_time, :end_time, :date)
    end

end
