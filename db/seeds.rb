# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Visualisation.all.empty?
for i in 1..10
  Visualisation.create([
    {:name => "Milan", 
       :link => "/assets/dummy/milan.png", 
       :approved => true,
       :vis_type => :vis,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."}, 
      {:name => "Green",
       :approved => true,
       :vis_type => :vis,
       :link => "/assets/dummy/green.png",
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."},
      {:name => "Pink", 
       :approved => true,
       :vis_type => :vis,
       :link => "/assets/dummy/pink.png",
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."}, 
      {:name => "Power", 
       :link => "/assets/dummy/power.png",
       :approved => true,
       :vis_type => :advert,
       :isDefault => true,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."}, 
    ])
end
  for i in 1..10
    Visualisation.create([
      {:name => "Milan", 
       :link => "/assets/dummy/milan.png", 
       :vis_type => :vis,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."}, 
      {:name => "Green",
       :link => "/assets/dummy/green.png",
       :vis_type => :vis,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."},
      {:name => "Pink", 
       :link => "/assets/dummy/pink.png",
       :vis_type => :vis,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."}, 
      {:name => "Power", 
       :link => "/assets/dummy/power.png",
       :vis_type => :advert,
       :isDefault => true,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."}, 
    ])
  end
end
               
