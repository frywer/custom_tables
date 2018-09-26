module CustomTables
  module ActsAsJournalize
    extend ActiveSupport::Concern
    included do

      cattr_accessor :journal_options
      self.journal_options = {}

      default_options = { non_journalized_columns: %w(id created_on updated_on updated_at created_at lft rgt lock_version),
                         important_columns: [],
                         format_detail_date_columns: [],
                         format_detail_time_columns: [],
                         format_detail_reflection_columns: [],
                         format_detail_boolean_columns: [],
                         format_detail_hours_columns: []
      }

      cattr_accessor :journalized_options
      self.journalized_options = default_options.dup

      journal_options.each do |k,v|
        self.journalized_options[k] = Array(self.journalized_options[k]) | v
      end

      safe_attributes 'notes'

      has_many :journals, as: :journalized, dependent: :destroy, inverse_of: :journalized

      attr_reader :current_journal
      delegate :notes, :notes=, :private_notes, :private_notes=, to: :current_journal, allow_nil: true

      after_commit :create_journal
    end

    def init_journal(user, notes = '')
      @current_journal ||= Journal.new(journalized: self, user: user, notes: notes)
    end

    def journalized_attribute_names
      self.class.column_names - self.journalized_options[:non_journalized_columns]
    end

    def notified_users
      if project
        project.notified_users.reject {|user| !visible?(user)}
      else
        [User.current]
      end
    end

    def current_journal
      @current_journal
    end

    private

    def create_journal
      if @current_journal
        @current_journal.save
      end
    end

  end

end