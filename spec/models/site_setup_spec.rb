require 'rails_helper'

RSpec.describe SiteSetup, type: :model do
  include_context "debug setup"

  describe "validations" do
    it "validates presence of configuration_name" do
      site_setup = SiteSetup.new(site_name: "Example Site", site_domain: "example.com", site_host: "host.example.com", site_url: "http://example.com")
      expect(site_setup.valid?).to be false
      expect(site_setup.errors[:configuration_name]).to include("can't be blank")
    end

    it "validates presence of site_name" do
      site_setup = SiteSetup.new(configuration_name: "Default Config", site_domain: "example.com", site_host: "host.example.com", site_url: "http://example.com")
      expect(site_setup.valid?).to be false
      expect(site_setup.errors[:site_name]).to include("can't be blank")
    end

    it "validates presence of site_domain" do
      site_setup = SiteSetup.new(configuration_name: "Default Config", site_name: "Example Site", site_host: "host.example.com", site_url: "http://example.com")
      expect(site_setup.valid?).to be false
      expect(site_setup.errors[:site_domain]).to include("can't be blank")
    end

    it "validates presence of site_host" do
      site_setup = SiteSetup.new(configuration_name: "Default Config", site_name: "Example Site", site_domain: "example.com", site_url: "http://example.com")
      expect(site_setup.valid?).to be false
      expect(site_setup.errors[:site_host]).to include("can't be blank")
    end

    it "validates presence of site_url" do
      site_setup = SiteSetup.new(configuration_name: "Default Config", site_name: "Example Site", site_domain: "example.com", site_host: "host.example.com")
      expect(site_setup.valid?).to be false
      expect(site_setup.errors[:site_url]).to include("can't be blank")
    end

    it "is valid with all required attributes" do
      site_setup = SiteSetup.new(
        configuration_name: "Default Config",
        site_name: "Example Site",
        site_domain: "example.com",
        site_host: "host.example.com",
        site_url: "http://example.com"
      )
      expect(site_setup.valid?).to be true
    end
  end
end
