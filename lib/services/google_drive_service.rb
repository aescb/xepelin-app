require 'google_drive'

module Services
  class GoogleDriveService
    FOLDER_URL = 'https://drive.google.com/drive/folders/1jk3p5-DTgvtu3B59L6XnCay8d5WY68v0'.freeze

    def self.build_session
      decoded_json_key = Base64.decode64(Rails.application.credentials[:gcp_encoded_secret_sheets])
      json_key_io = StringIO.new(decoded_json_key)
      GoogleDrive::Session.from_service_account_key(json_key_io)
    end

    def self.upload_report(file_path)
      session = build_session
      file = session.upload_from_file(file_path, "#{Time.now}_reporte_blog", content_type: 'text/csv')
      folder = session.folder_by_url(FOLDER_URL)
      folder.add(file)
      file.human_url.split('/edit').first
    end
  end
end