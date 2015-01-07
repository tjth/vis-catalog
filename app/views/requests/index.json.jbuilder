json.array!(@requests) do |request|
  json.extract! request, :id, :name, :company, :email, :notes, :desired_username
  json.url request_url(request, format: :json)
end
