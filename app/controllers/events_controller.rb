class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.order('published desc').page(params[:page]).per(50)
    @event_groups = grouped_by(@events)
  end

  private
    # FIXME: Group by key, but the key value is the event item itself
    def grouped_by(events)
      by_date = -> (event) { event.published.to_date }
      by_provider = -> (event) { [event.provider['type'], event.provider['id']].join }
      groups = {}
      events.group_by { |e| by_date.call(e) }.each do |k, v|
        # Group by uninterruptedly provider
        subs, curr = [], []
        v.each_with_index do |o, i|
          # The same with previous element, then add into the current group
          if i > 0 && by_provider.call(o) == by_provider.call(v[i-1])
            curr << o
          # Not the same, then create a new group
          else
            curr = [o]
            subs << curr
          end
        end

        # Key -> Event Object
        sub = {}
        subs.map {|v| sub[v.first] = v }

        groups[v.first] = sub
      end
      groups
    end
end
