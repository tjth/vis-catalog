json.array!(@users) do |u|
   json.extract! u, :username, :isAdmin, :isApproved, :id, :avatar
end
