json.array!(@visualisations) do |visualisation|
  if @expandAuthor != nil
    json.extract! visualisation, :id, :name, :link, :description, :notes, :approved, :author_info
  else 
  	json.extract! visualisation, :id, :name, :link, :description, :notes, :approved
  end
end
