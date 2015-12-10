require 'action_controller'

ActionController::Base.class_eval do
  require 'extensions/project_exception'

  rescue_from Exception, :with => :exception_work, :except => [:save_exception_info]

  def select_layout
    'application'
  end

  private

  def cnt_path_to_module_name(cnt_path)
    cnt_path.split('/').first.split('_').map{|elem| "#{elem[0].to_s.upcase}#{elem[1..-1]}"}.join('')
  rescue => exp
    puts "cnt_path_to_module_name Error: #{exp.message}"
    cnt_path
  end

  def exception_work(exp)
    # puts exp.backtrace.join("\n")
    if exp.class == ProjectException
      # puts exp.backtrace.join("\n")
      case exp.message
        when 'NotAccessModule'
          show_error(t 'exceptions.modul_is_not_access')
        when 'NotAccessAction'
          show_error(t 'exceptions.action_is_not_access')
        when 'AccountIsNULL'
          show_error(t 'exceptions.shtatnoe_is_null')
        when 'InputDateNotTrue'
          show_error(t 'exceptions.date_is_not_true')
        when 'FileIsNotSelect'
          show_error(t 'exceptions.data_file.select_error')
        when 'ErrorFileOperation'
          show_error(t 'exceptions.data_file.file_system_error')
        when 'FileFindOfNull'
          show_error(t 'exceptions.data_file.find_of_null')
        when 'RecordSaveUpdateError', 'BD_Save_Update_ERROR'
          show_error(t 'exceptions.error_bd')
        when 'UserNotRight'
          show_error(t 'exceptions.user_not_right')
        when 'ObjectIsNull'
          show_error(t 'exceptions.object_is_null')
        when 'ParamsUnCorrect'
          show_error(t 'exceptions.params_incorrect')
        when 'AlreadyIsList'
          show_error(t 'exceptions.already_is_list')
        when 'ErrorXHR'
          show_error(t 'exceptions.error_xhr')
        else
          if exp.message.start_with?('ShowMessage: ')
            show_error exp.message.sub('ShowMessage: ', '')
          elsif exp.message.start_with?('NotAccessModule') || exp.message.start_with?('NotAccessAction')
            right_name =  exp.message.sub('NotAccessModule: ', '').sub('NotAccessAction: ', '')
            show_error "#{t('exceptions.modul_is_not_access')} [ #{right_name} ]"
          else
            working_other_exception(exp)
          end
      end
    elsif ['ActiveRecord::RecordInvalid', 'RecordInvalid'].include? exp.class.to_s
      show_error(t 'exceptions.record_invalid')
    elsif exp.class == PG::Error && exp.message.start_with?('ERROR:  duplicate key value violates unique constraint')
      show_error(t 'error.pg_errors.duplicate')
    elsif exp.class == ActionView::MissingTemplate
      if env_development?
        show_error("#{t 'exceptions.template_find_empty'} [#{exp.message}]")
      else
        puts_error_message exp
        show_error(t 'exceptions.template_find_empty')
      end
    else
      working_other_exception(exp)
    end
  end

  def working_other_exception(exp)
    # exp.class == ProjectException
    m_name = "work_exception_#{controller_path.split('/').first}"
    if eval("defined? #{m_name}")
      begin
        eval "#{m_name} exp"
      rescue => method_exp
        working_unknown_exception method_exp
      end
    else
      working_unknown_exception exp
    end
  end

  def working_unknown_exception(exp)
    if env_development?
      @error_message = exp.message
      if request.xhr?
        puts_error_message(exp)
      end
      respond_to do |format|
        format.html{raise exp}
        format.js{render(:partial => 'rails_exceptions/show_error', :handlers => [:erb], :formats => [:js])}
      end
    else
      save_exception_info(exp)
      show_error(t 'exceptions.unknown_error')
    end
  end

  def show_error(error_message, error_title = I18n.t('exceptions.title'))
    @error_title = error_title
    @error_message = error_message
    respond_to do |format|
      format.html{render 'rails_exceptions/error', layout: select_layout}
      format.js{render(:partial => 'rails_exceptions/show_error', :handlers => [:erb], :formats => [:js])}
    end
  end

  def proverka_zaprosa_on_xhr
    unless request.xhr?
      raise ProjectException, 'ErrorXHR'
    end
  end


  def save_exception_info(exp, controller_class_name = 'RailsExceptions')
    unless env_development?
      user_id = session[:user_id] || (session[:user] ? session[:user][:id] : '')


      if RailsExceptions.save_exception_info

        unless RailsExceptions::LogError.where(["error_class_name = ? and error_message = ? and user_id = ?
             and created_at BETWEEN current_timestamp-time '00:05' AND current_timestamp", exp.class, exp.message, user_id.to_i]).any?
          RailsExceptions::LogError.transaction do
            @log_error = RailsExceptions::LogError.new
            @log_error.user_id = user_id.to_i
            @log_error.request_url = request.url
            @log_error.request_ip = request.remote_ip
            @log_error.request_method = request.request_method
            @log_error.error_class_name = exp.class.to_s
            @log_error.error_message = exp.message
            @log_error.error_backtrace = exp.backtrace.join("\n")
            @log_error.request_params = request.params.to_s
            # @log_error.save!
          end
        end
      end

      if RailsExceptions.mailer_exception_info
        exp_hash = {'error.user' => user_id,
                    'error.url' => request.url, 'error.request_ip' => request.remote_ip, 'error.html_method' => request.request_method, #"#{request.request_method} / XHR? #{request.xhr?}" ,
                    'error.class_name' => exp.class, 'error.error_message' => exp.message, 'error.time' => l(Time.now), 'error.backtrace' => exp.backtrace.join("\n")
        }
        # send_email_address = eval "#{controller_class_name}.send_email_address"
        # send_email_title = eval "#{controller_class_name}.send_email_title"

        m_name = "#{cnt_path_to_module_name(controller_path)}.send_email_address"
        send_email_address = eval("defined? #{m_name}") ? eval(m_name) : RailsExceptions.admin_email_address
        m_name = "#{cnt_path_to_module_name(controller_path)}.send_email_title"
        send_email_title = eval("defined? #{m_name}") ? eval(m_name) : I18n.t('exceptions.email_subject')
        # raise controller_

        # raise RailsExceptions::ErrorsMailer.smtp_settings.to_s
        RailsExceptions::ErrorsMailer.send_error(exp_hash, send_email_address, send_email_title)
      end
    end
  end


  def puts_error_message(exp)
    puts '#------------------#'
    puts 'Message: ' + exp.message
    puts 'Trace: '
    puts exp.backtrace.join("\n")
    puts '#------------------#'
  end

  def env_development?
    Rails.env.development? #&& request.remote_ip.to_s == '127.0.0.1'
  end


end