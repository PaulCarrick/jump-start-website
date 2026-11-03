# frozen_string_literal: true

module AdminDefaultsSeed
  module_function

  def load!
    data = JSON.parse(File.read(File.join(__dir__, 'admin_defaults.json')))
    PublishingContext.set(editing: false, deploying: false, live: false, preview: false) do
      CatalogRecord.transaction do
        # Serialize seed runs using the same lock as publishing.
        CatalogRecord.connection.execute('SELECT pg_advisory_xact_lock(87342, 1)')
        if data.fetch('users').any? { |row| !User.unscoped.where('LOWER(email) = ?', row.fetch('email').downcase).exists? }
          raise 'USER_PASSWORD is required when seeding new users' if ENV['USER_PASSWORD'].blank?
        end
        seed_setup!(data.fetch('site_setup').fetch(0))
        seed_navigation!(MenuItem, data.fetch('menu_items'))
        seed_navigation!(FooterItem, data.fetch('footer_items'))
        seed_home!(data)
        seed_users!(data.fetch('users'))
      end
    end
    SiteRoutes.clear!
  end

  def seed_users!(rows)
    missing = rows.reject { |row| User.unscoped.where('LOWER(email) = ?', row.fetch('email').downcase).exists? }
    return if missing.empty?

    password = ENV.fetch('USER_PASSWORD')
    raise 'USER_PASSWORD must not be blank when seeding new users' if password.blank?

    missing.each do |row|
      User.create!(row.merge('password' => password, 'password_confirmation' => password))
    end
  end

  def seed_setup!(row)
    existing = SiteSetup.unscoped.where(default_setup: true)
      .or(SiteSetup.unscoped.where(configuration_name: row.fetch('configuration_name')))
      .or(SiteSetup.unscoped.where(database: row.fetch('database')))
    return if existing.exists?

    attributes = row.except('id', 'routing_host', 'routing_path').transform_values do |value|
      value.is_a?(Hash) && value.key?('env') ? ENV.fetch(value.fetch('env')) : value
    end
    # Legacy setups stored a bare hostname; current validation requires a URL.
    unless attributes.fetch('site_url').match?(%r{\Ahttps?://}i)
      attributes['site_url'] = "https://#{attributes.fetch('site_url')}"
    end
    SiteSetup.create!(attributes)
  end

  def seed_home!(data)
    pages = {}
    data.fetch('pages').each do |row|
      existing = Page.unscoped.where(name: row.fetch('name'))
        .or(Page.unscoped.where(section: row.fetch('section')))
      pages[row.fetch('id')] = existing.order(version: :desc).first || Page.create!(
        row.except('id', 'menu_item_id', 'footer_item_id')
      )
    end

    sections = {}
    data.fetch('sections').each do |row|
      page = pages.fetch(row.fetch('page_id'))
      sections[row.fetch('id')] = Section.unscoped.where(section_name: row.fetch('section_name'))
        .order(version: :desc).first || Section.create!(
          row.except('id', 'page_id', 'checksum').merge('page_id' => page.id, 'content_type' => page.section)
        )
    end
    data.fetch('cells').each do |row|
      section = sections.fetch(row.fetch('section_id'))
      next if Cell.unscoped.where(cell_name: row.fetch('cell_name'), section_id: section.id).exists?

      Cell.create!(row.except('id', 'section_id', 'checksum').merge(
        'section_id' => section.id, 'section_name' => section.section_name
      ))
    end
  end

  def seed_navigation!(model, rows)
    remaining = rows.index_by { |row| row.fetch('id') }
    records = {}
    until remaining.empty?
      ready = remaining.values.select { |row| !remaining.key?(row['parent_id']) }
      raise 'Circular parent references in admin navigation seeds' if ready.empty?

      ready.each do |row|
        # Never reuse source IDs: the destination may already contain other data.
        existing = model.unscoped.where(link: row.fetch('link'))
        existing = existing.where(label: row.fetch('label')) if row['link'].blank?
        existing = existing.where(menu_type: row['menu_type']) if model == MenuItem
        records[row.fetch('id')] = existing.order(version: :desc).first || model.create!(
          row.except('id', 'parent_id', 'page_id').merge(
            'parent_id' => records[row['parent_id']]&.id, 'page_id' => nil
          )
        )
        remaining.delete(row.fetch('id'))
      end
    end
  end
end
