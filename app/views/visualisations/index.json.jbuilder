json.array!(@visualisations) do |visualisation|
  json.extract! visualisation, :id, :name, :link, :description, :notes, :updated_at, :created_at, :approved
  if @expandAuthor == true
    json.extract! visualisation, :author_info
  end
end
