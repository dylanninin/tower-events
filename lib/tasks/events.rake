namespace :events do
  desc 'do shuffle tasks to generate events'
  task :shuffle, [:limit] => [:environment] do |_, args|
    FG = FactoryGirl
    limit = args.limit&.strip || 10
    tms = TeamMember.order('random()').take(limit)
    tms.each do |t_m|
      u = t_m.member
      t = t_m.team
      User.current = u

      Comment.where(team: t).order('random()').limit(limit).each do |c|
        FG.create(:comment, replied_to_id: c.id, commentable: c.commentable, team: t, creator: u)
      end

      Project.where(team: t).each do |pro|
        # create new todo list
        FG.create_list(:todo_list, 2, project: pro, team: t, creator: u).each do |tl|
          FG.create_list(:todo, rand(1...5), todo_list: tl, project: pro, team: t, creator: u, assignee_id: nil)
          User.current = tms.sample.member
          FG.create_list(:todo, rand(1...5), todo_list: tl, project: pro, team: t, creator: u).each do |i|
            cs = FG.create_list(:comment, rand(1...5), commentable: i, team: t, creator: u)
            FG.create(:comment, replied_to_id: cs.sample.id, commentable: i, team: t, creator: u)
          end
        end
        # create new calendar event
        User.current = u
        FG.create_list(:calendar_event, rand(1...5), calendarable: pro, team: t, creator: u).each do |i|
          User.current = tms.sample.member
          cs = FG.create_list(:comment, rand(1...5), commentable: i, team: t, creator: u)
          FG.create(:comment, replied_to_id: cs.sample.id, commentable: i, team: t, creator: u)
        end

        User.current = u
        Todo.where(project: pro).order('random()').limit(limit).each do |todo|
          todo.assignee = Access.where(accessable: pro).order('random()').first.user
          todo.save

          todo.due_to = Date.today + rand * rand(1...14)
          todo.save

          User.current = tms.sample.member
          if todo.completed?
            todo.status = 'open'
          elsif todo.paused?
            todo.status = 'running'
          else
            todo.status = 'completed'
          end
          todo.save
        end
      end
    end
  end
end
