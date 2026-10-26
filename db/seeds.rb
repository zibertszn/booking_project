# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Resource.find_or_create_by!(name: "Переговорная A") do |resource|
  resource.description = "Комната для командных встреч с экраном и доской."
  resource.resource_type = "property"
end

Resource.find_or_create_by!(name: "Проектор Epson") do |resource|
  resource.description = "Проектор для презентаций и учебных мероприятий."
  resource.resource_type = "item"
end
