# frozen_string_literal: true

require "spec_helper"
require File.expand_path("../support/more_previews_helpers", __dir__)

describe AttachmentsController, type: :controller do
  include MorePreviewsHelpers

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :enabled_modules, :issues, :trackers, :projects_trackers, :issue_statuses, :enumerations

  before do
    enable_libre_odt_converter
    Project.find(1).enable_module!(:redmine_more_previews)
    @request.session[:user_id] = 1
  end

  around { |example| with_tmp_attachments_directory(&example) }

  describe "GET show" do
    it "renders the preview of a convertible file" do
      attachment = create_attachment("report.odt", "content")

      get :show, params: { id: attachment.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template("attachments/more_preview")
    end

    it "renders the standard page of an empty file stored under another extension" do
      # Empty files share the same digest, so Redmine reuses the stored file of another attachment
      create_attachment("trace.log", "")
      attachment = create_attachment("report.odt", "")
      expect(attachment.disk_filename).to end_with("trace.log")

      get :show, params: { id: attachment.id }

      expect(response).to have_http_status(:success)
      expect(response).not_to render_template("attachments/more_preview")
    end
  end
end
