class ImportBoardingHousesJob < ActiveJob::Base
  queue_as :data_import

  FileWrapper = Struct.new(:path, :original_filename, keyword_init: true)

  def perform(signed_blob_id, academy_id = nil)
    blob = ActiveStorage::Blob.find_signed!(signed_blob_id)
    academy = academy_id.present? ? Academy.find(academy_id) : nil

    blob.open do |tempfile|
      file = FileWrapper.new(path: tempfile.path, original_filename: blob.filename.to_s)
      result = Services::BoardingHouseImporter.new(file: file, academy: academy).call
      Rails.logger.info(
        "[ImportBoardingHousesJob] created=#{result[:created]} " \
        "errors=#{result[:errors].size} skipped=#{result[:skipped]} total=#{result[:total]}"
      )
      result[:errors].each do |err|
        Rails.logger.warn("[ImportBoardingHousesJob] row #{err[:row]}: #{err[:errors].join(', ')}")
      end
    end
  ensure
    blob&.purge_later
  end
end
