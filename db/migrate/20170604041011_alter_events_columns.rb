class AlterEventsColumns < ActiveRecord::Migration[5.1]
  def change
    change_column_null :events, :actor, false
    change_column_null :events, :object, false

    # FIXME Postgres migration error on travis-ci
    # error:
    # => PG::DatatypeMismatch: ERROR:  column "actor" cannot be cast automatically to type jsonb
    # => HINT:  Specify a USING expression to perform the conversion.
    # => : ALTER TABLE "events" ALTER COLUMN "actor" TYPE jsonb
    # https://travis-ci.org/dylanninin/tower-events/builds/239363174
    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table "events"
          alter column "actor" type jsonb using actor::jsonb,
          alter column "object" type jsonb using object::jsonb,
          alter column "target" type jsonb using target::jsonb,
          alter column "provider" type jsonb using provider::jsonb,
          alter column "generator" type jsonb using generator::jsonb
        SQL
      end

      dir.down do
        execute <<-SQL
          alter table "events"
          alter column "actor" type json using actor::json,
          alter column "object" type json using object::json,
          alter column "target" type json using target::json,
          alter column "provider" type json using provider::json,
          alter column "generator" type json using generator::json
        SQL
      end
    end
  end

end
