module CustomReport
  class Report < ActiveRecord::Base
    belongs_to :administrator, :polymorphic => true
    has_many :report_check_items

    validates_presence_of :name

    serialize :columns

    attr_accessor :iterator

    def generate(options = {}, filter_args = {})
      result = []
      ActiveRecord::Base.transaction do
        # Create the scope
        @iterator = eval(self.scope)

        unless options[:dont_paginate]
          @iterator = @iterator.paginate :page => options[:page], :per_page => (options[:per_page] || 20)
        end

        # Return an array of hashes
        result = @iterator.map do |entity|
          self.columns.map do |column|
            accessor = column[1]
            if column[2] == "eval"
              entity.instance_eval(accessor)
            else
              accessor.split(".").inject(entity) { |current_entity, method| current_entity.try(method.to_sym) }
            end
          end
        end

        # Always roll back
        raise ActiveRecord::Rollback
      end
      result
    end

    def columns_yaml=(values)
      self.columns = YAML::load(values)
    end

    def columns_yaml
      self.columns.to_yaml
    end

    def columns_hash
      columns.map do |c|
        { :name => c[0], :format => c[2] }
      end
    end

  end
end
