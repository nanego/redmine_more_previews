# frozen_string_literal: true

require "spec_helper"
require File.expand_path("../support/more_previews_helpers", __dir__)

describe Attachment do
  include MorePreviewsHelpers

  fixtures :projects, :users, :issues, :trackers, :issue_statuses, :enumerations

  before { enable_libre_odt_converter }
  around { |example| with_tmp_attachments_directory(&example) }

  describe "#preview_convertible?" do
    it "is true for a file whose extension has an active converter" do
      expect(create_attachment("report.odt", "content")).to be_preview_convertible
    end

    it "is false for an empty file, as there is nothing to convert" do
      expect(create_attachment("report.odt", "")).not_to be_preview_convertible
    end

    it "is false for an extension without active converter" do
      expect(create_attachment("trace.log", "content")).not_to be_preview_convertible
    end
  end

  describe "#destroy" do
    it "deletes the stored file, the core caches and the previews of the plugin" do
      attachment = create_attachment("report.odt", "content")
      core_cache = attachment.send(:thumbnail_path, "100")
      FileUtils.mkdir_p([File.dirname(core_cache), attachment.preview_dirname])
      File.write(core_cache, "thumbnail")
      File.write(File.join(attachment.preview_dirname, "preview.pdf"), "preview")

      attachment.destroy

      expect(File.exist?(attachment.diskfile)).to be false
      expect(File.exist?(core_cache)).to be false
      expect(File.exist?(attachment.preview_storagepath)).to be false
    end
  end
end
