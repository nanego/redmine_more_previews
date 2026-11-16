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
end
