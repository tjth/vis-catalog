  json.id @visualisation.id
  json.name @visualisation.name
  json.link @visualisation.link
  json.description @visualisation.description
  json.notes @visualisation.notes
  json.approved @visualisation.approved
  json.vis_type @visualisation.vis_type
  json.content @visualisation.content
  json.screenshot @visualisation.screenshot
  json.min_playtime @visualisation.min_playtime
  json.content_type @visualisation.content_type

  json.author do
    json.username @visualisation.user.username
    json.avatar @visualisation.user.avatar
  end

