module HistoryScopeCompatibility
  # 0.4.0 assumes every non-nil association scope has this predicate. Mark only
  # the affected scopes before delegating; do not patch Proc globally.
  def const_missing(name)
    source = [ instance_variable_get(:@root), name ].compact.join('::').constantize
    return super unless source.is_a?(Class) && source < ActiveRecord::Base
    source.reflect_on_all_associations.each do |reflection|
      scope = reflection.scope
      scope.define_singleton_method(:temporal_scope?) { false } if scope && !scope.respond_to?(:temporal_scope?)
    end
    model = super
    if source < BitemporalRecord
      model.primary_key = [ :id, :version, :system_period ]
      model.after_find :readonly!
    end
    # The beta calls a nonexistent version_model for polymorphic associations.
    model.define_singleton_method(:polymorphic_class_for) do |type|
      target = source.polymorphic_class_for(type)
      target.respond_to?(:history_model) ? target.history_model : target
    end
    model
  end
end

module History
  include ActiveRecord::Temporal::HistoryModelNamespace
  extend HistoryScopeCompatibility

  # Immutable blobs and retained attachments use their existing framework tables.
  namespace :ActiveStorage do
    extend HistoryScopeCompatibility
  end
end
