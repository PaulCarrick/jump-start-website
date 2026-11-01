# The authoritative setup catalog always uses the original Rails connection.
# ApplicationRecord alone is sharded; framework cache/queue connections stay put.
class CatalogRecord < ActiveRecord::Base
  self.abstract_class = true
end
