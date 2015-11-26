module RailsExceptions
  class ErrorsMailer < ::ActionMailer::Base
    default from: RailsExceptions.support_email_address
    # self.raise_delivery_errors = true

    def send_error(exp_hash, send_email_address, send_email_title)
      if RailsExceptions.admin_email_address && RailsExceptions.support_email_address
        @exp_hash = exp_hash
        send_email_address = send_email_address.class == Array ? send_email_address.join(', ') : send_email_address
        # error_email_to = 'sadfjhk'
        mail(:to => send_email_address, :subject => send_email_title).deliver
      else
        puts 'Enter params: RailsExceptions.admin_email_address; RailsExceptions.support_email_address'
      end
    end

  end

end