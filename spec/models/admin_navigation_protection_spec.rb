require 'rails_helper'

# Menu and footer items that link to the admin can be moved, not changed.
RSpec.describe AdminNavigationProtection, type: :model do
  def editing(&block) = PublishingContext.set(editing: true, deploying: false, live: false, preview: false, &block)

  let!(:item) { create(:footer_item, label: 'Admin Dashboard', link: '/admin', icon: nil, options: nil, access: nil, footer_order: 3) }

  it 'lets an admin link move when its form sends blank fields back as empty text' do
    editing { FooterItem.find(item.id).update!(footer_order: 16, icon: '', options: '', access: '') }
    expect(FooterItem.pending_versions.find(item.id).footer_order).to eq(16)
  end

  it 'still refuses changing what an admin link says or where it goes' do
    editing do
      record = FooterItem.find(item.id)
      expect(record.update(label: 'Somewhere else')).to be(false)
      expect(record.errors[:base]).to include('Items linking to /admin are read-only.')
    end
  end
end
