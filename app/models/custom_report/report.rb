module CustomReport
  class Report < ActiveRecord::Base
    belongs_to :administrator, :polymorphic => true
    has_many :report_check_items

    validates_presence_of :name

    validate :unharmful

    serialize :columns

    attr_accessor :iterator

    def generate(options = {}, filter_args = {})
      result = []
      ActiveRecord::Base.transaction do
        # Create the scope
        begin
          @iterator = eval(self.scope) unless self.scope.include?("destroy")

          unless options[:dont_paginate]
            @iterator = @iterator.paginate :page => options[:page], :per_page => (options[:per_page] || 20)
          end

          # Return an array of hashes
          result = @iterator.map do |entity|
            self.columns.map do |column|
              evaluate(entity, column)
            end
          end

        ensure
          # Always roll back
          raise ActiveRecord::Rollback
        end
      end
      result
    end

    def evaluate(entity, column)
      accessor = if column.is_a?(Hash) and column.size == 1
        column.values.first
      else
        column[1]
      end

      unless accessor.include?("destroy")
        entity.instance_eval(accessor)
      end
    end

    def columns_yaml=(values)
      self.columns = YAML::load(values)
    end

    def columns_yaml
      self.columns.to_yaml
    end

    def columns_hash
      columns.map do |c|
        if c.is_a?(Array)
          { :name => c[0], :format => c[2] }
        else
          { :name => c.keys.first, :format => nil }
        end
      end
    end

    def unharmful
      if scope.include?(".destroy")
        errors.add(:scope, 'Scope cannot destroy - unsafe!')
      end
    end

  end
end
