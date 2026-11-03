# frozen_string_literal: true

require_relative 'seeds/admin_defaults'

# Captured from the current local site's deployed configuration. Missing records
# are created live; existing records (including drafts) are never overwritten.
AdminDefaultsSeed.load!
