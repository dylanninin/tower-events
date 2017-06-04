class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.order('published desc').page(params[:page]).per(50)
    @event_groups = @events.group_by { |event| event.published.to_date }
  end
end
