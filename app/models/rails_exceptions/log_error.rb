module RailsExceptions
  class LogError < ActiveRecord::Base
    self.table_name = 'log.log_errors'

    attr_accessible :created_at, :user_id, :request_url, :request_ip, :request_method, :error_class_name, :error_message, :error_backtrace, :request_params
  end
end