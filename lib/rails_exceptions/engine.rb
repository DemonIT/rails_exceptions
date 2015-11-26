module RailsExceptions
  class Engine < ::Rails::Engine
    isolate_namespace RailsExceptions

    engine_name :rails_exception


    initializer 'rails_exceptions.assets.precompile' do |app|
      app.config.assets.precompile += %w( rails_exceptions/error.css rails_exceptions/error.js )
    end
  end
end
