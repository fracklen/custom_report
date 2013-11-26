module CustomReport
  class ReportsController < ::ApplicationController
    layout CustomReport.layout

    if CustomReport.includes
      Array(CustomReport.includes).each do |inc|
        include inc
      end
    end

    if CustomReport.before_filters
      Array(CustomReport.before_filters).each do |filter|
        before_filter filter
      end
    end

    def index
      @custom_reports = custom_reports
    end

    def show
      @report = custom_report
      respond_to do |format|
        format.html {
          get_the_report
        }
        format.csv {
          params[:dont_paginate] = 1
          get_the_report
          render_csv @results, :filename => "#{custom_report.name.parameterize}-#{Time.now.strftime("%Y%m%d%H%M%S")}", :columns => @columns
        }
      end
    end

    def get_the_report
      begin
        @filters = []

        @filters.each do |filter|
          if filter.first == "options"
            filter.each do |key|
              next if key == "options"
              params[key.to_sym] = true
            end
          end
        end
        @filters.reject! {|f| f.first == "options" }

        @filter_args = params[:filters] || {}
        @results = @report.generate(params, @filter_args)
        @iterator = @report.iterator
        @columns = @report.columns_hash
        @check_items = @report.report_check_items.group_by(&:item_id)

        @report.update_column(:last_opened, Time.current)
      rescue Exception => e
        render :text => "<strong>Error:</strong> <p>#{e.class}: #{e.message}</p><p style='font-family: monospace;'>#{e.backtrace.join("<br>")}</p>"
      end
    end

    def new
      @report = CustomReport::Report.new
    end

    def create
      @report = CustomReport::Report.new(
        :name => params[:report][:name],
        :category => params[:report][:category],
        :description => params[:report][:description],
        :scope => params[:report][:scope],
        :columns_yaml => params[:report][:columns_yaml]
        )
      @report.save
      redirect_to report_path(@report)
    end

    def edit
      set_return_path
      @report = CustomReport::Report.find(params[:id])
    end

    def update
      set_return_path
      if custom_report.update_attributes({"has_checklist" => "false"}.merge(params[:report]).merge(:administrator_type => CustomReport.admin_class))
        redirect_to @return_path
      else
        render "edit"
      end
    end

    def unarchive
      custom_report.update_column(:deleted_at, nil)
      redirect_to custom_reports_path(:show_archived => 1)
    end

    def format_column(entity, column, column_index)
      format = column[:format] || "text"
      raw = entity[column_index].to_s

      case format
      when "text"
        raw
      when "strong"
        "<strong>#{raw}</strong>"
      when "impersonate"
        view_context.link_to "Impersonate", impersonate_path(:email => raw)
      when "eval"
        raw.html_safe
      else
        "unknown formatter: #{format}"
      end
    end
    helper_method :format_column

    def custom_reports
      scope = CustomReport::Report.order("category,name")
      scope = scope.where(:administrator_id => params[:show_for]) if params[:show_for].present?
      scope = scope.where("custom_report_reports.deleted_at IS NULL") unless params[:show_archived].present?
      scope.group_by(&:category)
    end

    def custom_report
      if params[:id]
        CustomReport::Report.includes(:report_check_items).find params[:id]
      elsif params[:report]
        CustomReport::Report.new(params[:report])
      else
        CustomReport::Report.new(:name => "Custom Report", :columns => [["Column 1", "some_method"], ["Column 2", "some_other_method"]])
      end
    end

    def toggle_check_item
      @item = CustomReport::ReportCheckItem.where(:report_id => params[:id], :item_id => params[:item_id]).first

      unless @item
        @item = CustomReport::ReportCheckItem.new
        @item.report_id = params[:id]
        @item.item_id = params[:item_id]
        @item.save!
      else
        @item.destroy
      end
      render :nothing => true
    end

    def remove_all_check_items
      CustomReport::ReportCheckItem.where(:report_id => params[:id]).delete_all

      render :js => "$('.check_item').attr('checked',false);"
    end

    def destroy
      custom_report.update_column(:deleted_at, Time.current)
      redirect_to reports_path
    end

    private

    def set_return_path
      @return_path = params[:return_path] || reports_path
    end

    def my_object
      "custom_report"
    end

    def render_csv(iterator, options = {})
      filename = options[:filename] || "#{params[:action]}-#{Time.now.strftime("%Y%m%d%H%M%S")}"
      filename << '.csv'

      if request and request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain"
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = "0"
      else
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end

      text = CSV.generate do |csv|
        csv << @columns.map { |column| column[:name] }

        iterator.each do |entity|
          csv << @columns.each_with_index.map do |column, index|
            format_column(entity, column, index)
          end
        end
      end

      render :layout => false, :inline => text
    end

    def method_missing(name, *args, &block)
      main_app.send(name, *args, &block)
    end
    helper_method :method_missing

    def administrator_class
      if CustomReport.admin_class
        CustomReport.admin_class.constantize
      else
        nil
      end
    end
    helper_method :administrator_class
  end


end
