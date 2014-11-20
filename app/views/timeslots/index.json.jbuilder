json.array!(@timeslots) do |timeslot|
   json.extract! timeslot, :start_time, :end_time, :date
end
