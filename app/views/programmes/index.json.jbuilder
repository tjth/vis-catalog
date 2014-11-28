json.array!(@programmes) do |p|
   json.extract! p, :screens, :priority, :visualisation_id, :timeslot_id
end
