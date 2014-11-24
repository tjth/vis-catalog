json.array!(@visualisations) do |visualisation|
  if @expandAuthor != nil
    json.extract! visualisation, :id, :name, :link, :description, :notes, :approved, :author_info, :created_at, :vis_type, :content, :screenshot, :min_playtime, :content_type
  else 
  	json.extract! visualisation, :id, :name, :link, :description, :notes, :approved, :created_at, :vis_type, :content, :screenshot, :min_playtime, :content_type
  end
end
