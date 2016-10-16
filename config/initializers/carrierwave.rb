# frozen_string_literal: true
class CarrierWave::Uploader::Base
  module Extensions
    def url
      if file.present? && ENV.key?('UPLOAD_URL_PREFIX')
        URI.join(ENV.fetch('UPLOAD_URL_PREFIX'), super).to_s
      else
        super
      end
    end
  end

  prepend Extensions
end
