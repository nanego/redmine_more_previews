# frozen_string_literal: true

require "spec_helper"
require File.expand_path("../support/more_previews_helpers", __dir__)

describe RedmineMorePreviews::Converter do
  include MorePreviewsHelpers

  before { enable_libre_odt_converter }

  describe ".conversion_ext" do
    let(:stored_file) do
      file = Tempfile.new(["240910131132_trace", ".log"])
      file.write("plain text")
      file.close
      file
    end

    after { stored_file.unlink }

    it "uses the extension of the given name when the stored file has another one" do
      expect(described_class.conversion_ext(stored_file.path, name: "report.odt")).to eq("pdf")
    end

    it "raises ConverterNotFound when neither the content nor the extension has an active converter" do
      expect { described_class.conversion_ext(stored_file.path) }.
        to raise_error(RedmineMorePreviews::Exceptions::ConverterNotFound)
    end
  end
end
