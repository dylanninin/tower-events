# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

return if Rails.env.production?

require 'factory_girl'
FG = FactoryGirl

10.times do
  u = FG.create(:user)
  t = FG.create(:team, creator: u)
  members = FG.create_list(:team_member, rand(1...5), member: FG.create(:user), team: t, creator: u).map(&:member)
  members << FG.create(:team_member, member: u, team: t, creator: u).member
  members.each do |m|
    FG.create(:access, accessable: t, user: m, team: t, creator: u)
  end
  FG.create_list(:project, 2, team: t, creator: u).each do | pro |
    members.each do |m|
      FG.create(:access, accessable: pro, user: m, team: t, creator: u)
    end
    FG.create_list(:todo_list, 2, project: pro, team: t, creator: u).each do |tl|
      FG.create_list(:todo, rand(1...5), todo_list: tl, project: pro, team: t, creator: u).each do |i|
        cs = FG.create_list(:comment, rand(1...5), commentable: i, team: t, creator: u)
        FG.create(:comment, replied_to_id: cs.sample.id, commentable: i, team: t, creator: u)
      end
    end
    FG.create_list(:calendar_event, rand(1...5), calendarable: pro, team: t, creator: u).each do |i|
      cs = FG.create_list(:comment, rand(1...5), commentable: i, team: t, creator: u)
      FG.create(:comment, replied_to_id: cs.sample.id, commentable: i, team: t, creator: u)
    end
  end
  FG.create_list(:report, 2, team: t, creator: u).each do |i|
    FG.create_list(:comment, rand(1...5), commentable: i, team: t, creator: u)
  end
  FG.create_list(:calendar, 2, team: t, creator: u).each do |cal|
    FG.create_list(:calendar_event, rand(1...5), calendarable: cal, team: t, creator: u).each do |i|
      cs = FG.create_list(:comment, rand(1...5), commentable: i, team: t, creator: u)
      FG.create(:comment, replied_to_id: cs.sample.id, commentable: i, team: t, creator: u)
    end
  end
end
