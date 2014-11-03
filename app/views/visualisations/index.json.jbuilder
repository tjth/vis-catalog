json.array!(@visualisations) do |visualisation|
  json.extract! visualisation, :id
  json.url visualisation_url(visualisation, format: :json)
end
