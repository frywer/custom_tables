module GladCustomTables
  module Patches
    module JournalsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do

          alias_method_chain :find_journal, :glad_custom_tables

          helper :custom_entities

          def edit_note
            find_journal
            respond_to do |format|
              format.js
              format.html
            end
          end
        end
      end

      module InstanceMethods

        def find_journal_with_glad_custom_tables
          @journal = Journal.find(params[:id])
          @project = @journal.journalized.try(:project) if @journal && @journal.journalized.respond_to?(:project)
        rescue ActiveRecord::RecordNotFound
          render_404
        end

      end
    end
  end
end

unless JournalsController.included_modules.include?(GladCustomTables::Patches::JournalsControllerPatch)
  JournalsController.send(:include, GladCustomTables::Patches::JournalsControllerPatch)
end
