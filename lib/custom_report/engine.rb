module CustomReport

  class Engine < Rails::Engine
    isolate_namespace CustomReport
    initializer "custom_report.load_app_instance_data" do |app|
      CustomReport.setup do |config|
        config.app_root = app.root
      end
    end

    initializer "custom_report.load_static_assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    module ApplicationHelper
      def method_missing(method, *args, &block)
        if (method.to_s.end_with?('_path') || method.to_s.end_with?('_url')) && main_app.respond_to?(method)
          main_app.send(method, *args)
        else
          super
        end
      end
    end

  end

end
