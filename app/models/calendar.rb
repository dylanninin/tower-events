class Calendar < ApplicationRecord
  include Eventable
  eventablize_opts actor: proc { User.current }, provider: :self, generator: :team,
                   as_json: {
                     only: [:name]
                   }
  eventablize_on :create
  eventablize_on :destroy

  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
