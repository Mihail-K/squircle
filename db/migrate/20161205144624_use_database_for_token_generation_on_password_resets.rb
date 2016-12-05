# frozen_string_literal: true
class UseDatabaseForTokenGenerationOnPasswordResets < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp'
    change_column_default :password_resets, :token, from: nil, to: 'uuid_generate_v4()'
  end
end
