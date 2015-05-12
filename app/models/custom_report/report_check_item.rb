module CustomReport
  class ReportCheckItem < ActiveRecord::Base
    attr_accessor :custom_report_id, :item_id

    belongs_to :report

    validates_presence_of :report_id
    validates_presence_of :item_id
  end
end
