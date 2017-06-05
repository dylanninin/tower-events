class AddIndicesToEvents < ActiveRecord::Migration[5.1]
  def change
    # For filter by generator, eg: all events of a team
    add_index :events, "((generator -> 'id'::text)), ((generator -> 'type'::text))", name: "index_events_on_generator", using: :gin
    # For filter by object, eg: all events on a object (todo|calendar_event|report) and , like `create`, `destroy`, `edit`, `set_due_to`, `assign`
    add_index :events, "((object -> 'id'::text)), ((object -> 'type'::text))", name: "index_events_on_object", using: :gin
    # For ordering by published
    add_index :events, ["published"], name: "index_events_on_published"
  end
end
