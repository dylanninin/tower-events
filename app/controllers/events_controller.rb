class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end
end
