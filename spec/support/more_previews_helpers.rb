# frozen_string_literal: true

module MorePreviewsHelpers
  def enable_libre_odt_converter
    Setting["plugin_redmine_more_previews"] = Setting["plugin_redmine_more_previews"].to_h.merge(
      "converter" => {
        "libre" => {
          "active" => "1",
          "mime_types" => { "odt" => { "active" => "1", "format" => "pdf" } }
        }
      }
    )
  end

  def with_tmp_attachments_directory
    previous = Attachment.storage_path
    Attachment.storage_path = Dir.mktmpdir("more_previews")
    yield
  ensure
    FileUtils.rm_rf(Attachment.storage_path)
    Attachment.storage_path = previous
  end

  def create_attachment(filename, content)
    file = Rack::Test::UploadedFile.new(StringIO.new(content), "application/octet-stream", original_filename: filename)
    Attachment.create!(container: Issue.find(1), file: file, author: User.find(1)).reload
  end
end
