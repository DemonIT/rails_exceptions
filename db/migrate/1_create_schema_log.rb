class CreateSchemaLog < ActiveRecord::Migration
  def up
    execute "CREATE SCHEMA log;" unless schema_exists? 'log'
  end

  def down
    execute "DROP SCHEMA log;"
  end
end