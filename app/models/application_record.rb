# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  connects_to shards: { default: { writing: ActiveRecord::Base.connection_db_config } }
end
