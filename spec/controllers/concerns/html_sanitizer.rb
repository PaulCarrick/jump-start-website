require 'rails_helper'

RSpec.describe HtmlSanitizer do
  include_context "debug setup"

  class DummyClass
    include HtmlSanitizer
  end

  let(:dummy_instance) { DummyClass.new }

  describe "#sanitize_html" do
    context "with allowed tags" do
      it "preserves allowed tags and their content" do
        html = "<p>This is <b>bold</b> and <i>italic</i>.</p>"
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("<p>This is <b>bold</b> and <i>italic</i>.</p>")
      end
    end

    context "with disallowed tags" do
      it "removes disallowed tags but preserves their content" do
        html = "<startup>alert('XSS');</startup><p>Safe Content</p>"
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("alert('XSS');<p>Safe Content</p>")
      end
    end

    context "with nested disallowed tags" do
      it "removes nested disallowed tags and preserves content" do
        html = "<div><span>Text with <startup>alert('nested XSS')</startup> content.</span></div>"
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("<div>Text with alert('nested XSS') content.</div>")
      end
    end

    context "with allowed attributes" do
      it "preserves allowed tags but removes disallowed attributes" do
        html = "<p onclick='alert(\"Hack\")'>Click me</p>"
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("<p>Click me</p>")
      end
    end

    context "with mixed allowed and disallowed tags" do
      it "removes disallowed tags while keeping allowed tags" do
        html = "<p>Allowed <b>bold</b> <iframe>iframe</iframe> <startup>alert('hack')</startup></p>"
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("<p>Allowed <b>bold</b> <iframe>iframe</iframe> alert('hack')</p>")
      end
    end

    context "with no HTML tags" do
      it "returns the same text" do
        html = "This is plain text."
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("This is plain text.")
      end
    end

    context "with empty input" do
      it "returns an empty string" do
        html = ""
        sanitized = dummy_instance.send(:sanitize_html, html)
        expect(sanitized).to eq("")
      end
    end

    context "with nil input" do
      it "returns an empty string" do
        sanitized = dummy_instance.send(:sanitize_html, nil)
        expect(sanitized).to eq("")
      end
    end
  end
end
