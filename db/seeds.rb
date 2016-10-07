# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Dir[Rails.root.join('db/seeds/**/*.rb')].sort.each do |file_name|
  require file_name
end

Doorkeeper::Application.find_or_create_by!(
  name:         'default',
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  uid:          '30ac6b5b2a676be9301471ffce4bf1c331c0eb28921f7d1269baea1a9ad6410a',
  secret:       'fb6bd09d8919b6c2d8fce0dd393a55cd568510fb39f0c14e9e31445ccc860393'
)

unless Rails.env.test?
  unless User.exists?
    User.create! email: 'admin@squircle.ca',
                 display_name: 'admin',
                 password: 'admin1234',
                 password_confirmation: 'admin1234',
                 date_of_birth: 20.years.ago,
                 roles: [Role.find_by!(name: :admin)]
  end

  unless Section.exists?
    Section.create! title: 'default',
                    description: 'The default forum section',
                    deleted: false,
                    creator: User.first
  end
end
