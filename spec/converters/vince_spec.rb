# frozen_string_literal: true

require "spec_helper"
require File.expand_path("../support/more_previews_helpers", __dir__)

describe "Vince converter" do
  include MorePreviewsHelpers

  fixtures :projects, :users, :issues, :trackers, :issue_statuses, :enumerations

  before do
    Setting["plugin_redmine_more_previews"] = Setting["plugin_redmine_more_previews"].to_h.merge(
      "converter" => {
        "vince" => {
          "active" => "1",
          "mime_types" => { "vcf" => { "active" => "1", "format" => "html" } }
        }
      }
    )
  end

  around { |example| with_tmp_attachments_directory(&example) }

  def html_preview(vcf)
    attachment = create_attachment("card.vcf", vcf)
    html = nil
    attachment.more_preview(format: "html") { |data| html = data }
    html.to_s
  end

  it "renders the card" do
    html = html_preview("BEGIN:VCARD\r\nVERSION:4.0\r\nFN:Jane Doe\r\nEND:VCARD\r\n")

    expect(html).to include("Jane Doe")
  end

  it "does not embed a server file referenced by the card" do
    server_file = Tempfile.new("server_file")
    server_file.write("server file content")
    server_file.close

    html = html_preview("BEGIN:VCARD\r\nVERSION:4.0\r\nFN:Jane Doe\r\nPHOTO:file://#{server_file.path}\r\nEND:VCARD\r\n")

    expect(html).to include("Jane Doe")
    expect(html).not_to include(Base64.encode64("server file content").strip)
  ensure
    server_file&.unlink
  end

  describe VinceLib::VObject::Modules::Escaping do
    let(:escaper) { Object.new.extend(described_class) }

    it "unescapes what it escapes" do
      value = "C:\\new folder\\, a;b\nc"

      expect(escaper.unesc_str(escaper.esc_str(value))).to eq(value)
    end
  end
end
