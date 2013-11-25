module CustomReport
  class ReportCheckItem < ActiveRecord::Base
    attr_accessible :custom_report_id, :item_id

    belongs_to :report

    validates_presence_of :custom_report_report_id
    validates_presence_of :custom_item_id

  end
end
