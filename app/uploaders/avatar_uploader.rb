# encoding: utf-8
# frozen_string_literal: true

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # include CarrierWave::Backgrounder::Delay

  # Use basic file storage for development.
  if Rails.env.development? || Rails.env.test?
    storage :file
  else
    storage :fog
  end

  def file_size
    128.bytes..2.megabytes
  end

  def store_dir
    "uploads/#{model.class.name.underscore}/#{mounted_as}/#{model.id}"
  end

  # Normalized version.
  version :medium do
    process resize_to_fit: [250, 250]
  end

  # Thumbnail version.
  version :thumb do
    process resize_to_fit: [100, 100]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def content_type_whitelist
    %r{image\/}
  end

  def filename
    return nil if original_filename.blank?
    require 'active_support/core_ext/digest/uuid'
    "#{Digest::UUID.uuid_v5(model.class.name, model.id.to_s)}.#{file.extension}"
  end
end
