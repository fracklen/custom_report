class CreateCustomReportTable < ActiveRecord::Migration
  def self.up
    create_table :custom_report_reports do |t|
      t.string   :name
      t.text     :description
      t.text     :scope
      t.text     :columns
      t.text     :filters
      t.boolean  :has_checklist
      t.integer  :administrator_id
      t.string   :administrator_type
      t.string   :category
      t.datetime :last_opened
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :custom_report_report_check_items do |t|
      t.integer  :report_id
      t.integer  :item_id
      t.timestamps
    end
  end

  def self.down
    drop_table :custom_report_report_check_items
    drop_table :custom_report_reports
  end
end
