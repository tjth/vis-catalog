json.array!(@visualisations) do |visualisation|
  if @expandAuthor != nil
    json.extract! visualisation, :id, :name, :link, :description, :notes, :approved, :author_info, :created_at
  else 
  	json.extract! visualisation, :id, :name, :link, :description, :notes, :approved, :created_at
  end
end
