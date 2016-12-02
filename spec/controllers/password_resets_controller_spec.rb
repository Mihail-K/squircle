# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  let :user do
    create :user
  end

  describe '#GET show' do
    let :password_reset do
      create :password_reset, email: user.email
    end

    it 'returns the specified password reset' do
      get :show, params: { token: password_reset.token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :password_reset

      expect(response.body).to include_json(password_reset: { token: password_reset.token })
    end
  end

  describe '#POST create' do
    it 'creates a password reset' do
      expect do
        post :create, params: { password_reset: { email: user.email } }

        expect(response).to have_http_status :created
        expect(response.body).to be_empty
      end.to change { user.password_resets.count }.by(1)
    end

    it 'creates a password reset unattached from a user' do
      expect do
        post :create, params: { password_reset: { email: Faker::Internet.email } }

        expect(response).to have_http_status :created
        expect(response.body).to be_empty
      end.not_to change { user.password_resets.count }
    end
  end

  describe '#PATCH update' do
    let :password_reset do
      create :password_reset, user: user
    end

    it 'completes the password reset' do
      expect do
        patch :update, params: { token: password_reset.token,
                                 password_reset: attributes_for(:password_reset, :closed) }

        expect(response).to have_http_status :ok
        expect(response).to match_response_schema :password_reset

        expect(response.body).to include_json(password_reset: {
          token: password_reset.token, status: 'closed'
        })
      end.to change { password_reset.reload.status }.from('open').to('closed')
    end

    it 'prevents the user from using a closed password reset' do
      password_reset.update_columns(status: 'closed')

      expect do
        patch :update, params: { token: password_reset.token,
                                 password_reset: attributes_for(:password_reset, :closed) }

        expect(response).to have_http_status :ok
      end.not_to change { user.reload.password_digest }
    end

    it 'prevents the user from reopening a password reset' do
      password_reset.update_columns(status: 'closed')

      expect do
        patch :update, params: { token: password_reset.token,
                                 password_reset: attributes_for(:password_reset, :open) }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors

        expect(response.body).to include_json(errors: { status: ["can't be changed"] })
      end.not_to change { password_reset.reload.status }
    end
  end
end
