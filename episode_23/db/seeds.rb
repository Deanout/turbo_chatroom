# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
dean = User.create(email: 'dean@example.com',
                   password: 'password',
                   password_confirmation: 'password',
                   role: 'admin')
User.create(email: 'john@doe.com',
            password: 'password',
            password_confirmation: 'password')
User.create(email: 'jane@doe.com',
            password: 'password',
            password_confirmation: 'password')
dean.joined_rooms << Room.create(name: 'General', is_private: false)
dean.joined_rooms << Room.create(name: 'Testing', is_private: false)
