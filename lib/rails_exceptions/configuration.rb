module RailsExceptions
  include ActiveSupport::Configurable
  config_accessor :errors_layout, :save_exception_info, :mailer_exception_info,
                  :admin_email_address, :support_email_address, :send_email_address, :send_email_title

  self.errors_layout = 'layouts/rails_exceptions/error'
  self.save_exception_info = true
  self.mailer_exception_info = true
  self.admin_email_address = ''
  self.support_email_address = ''
  self.send_email_address = ''
  self.send_email_title = ''
end
