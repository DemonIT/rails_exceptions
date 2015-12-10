class CreateLogErrors < ActiveRecord::Migration
  def change
    unless table_exists? 'log.log_errors'
      create_table 'log.log_errors' do |t|
        t.integer :user_id, limit: 8
        t.text :request_url
        t.column :request_ip, :inet
        t.text :request_method
        t.text :error_class_name
        t.text :error_message
        t.text :error_backtrace
        t.boolean :fixed
        t.text :request_params

        t.timestamps null: false
      end
      change_column 'log.log_errors', :id, :integer, limit: 8
    end
  end
end