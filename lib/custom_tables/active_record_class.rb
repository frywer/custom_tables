module CustomTables
  class ActiveRecordClass
    def self.base
      if Redmine::VERSION::MAJOR > 5
        ApplicationRecord
      else
        ActiveRecord::Base
      end
    end
  end
end