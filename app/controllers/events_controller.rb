class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.order('published desc')
    @event_groups = @events.group_by { |event| event.published.to_date }
  end
end
