# frozen_string_literal: true

require_relative 'seeds/admin_defaults'

# Generic defaults for a local site. Missing records
# are created live; existing records (including drafts) are never overwritten.
AdminDefaultsSeed.load! unless ENV['JUMPSTART_BOOTSTRAP'] == '1'
