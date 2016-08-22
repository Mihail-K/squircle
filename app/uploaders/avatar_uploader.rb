# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Backgrounder::Delay

  # Use basic file storage for development.
  if Rails.env.development? || Rails.env.test?
    storage :file
  else
    storage :fog
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
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

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def content_type_whitelist
    /image\//
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    return nil if original_filename.blank?
    require 'active_support/core_ext/digest/uuid'
    "#{Digest::UUID.uuid_v5(model.class.name, original_filename)}.#{file.extension}"
  end
end
