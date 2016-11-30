require 'rails_helper'

RSpec.describe EmailConfirmationsController, type: :controller do
  include_context 'authentication'

  describe '#GET show' do
    let :email_confirmation do
      create :email_confirmation
    end

    it 'returns the specified email confirmation' do
      get :show, params: { token: email_confirmation.token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :email_confirmation

      expect(response.body).to include_json(
        email_confirmation: { token: email_confirmation.token }
      )
    end
  end

  describe '#PATCH update' do
    let :email_confirmation do
      create :email_confirmation
    end

    it 'marks an email confirmation as confirmed' do
      expect do
        patch :update, params: { token: email_confirmation.token,
                                 email_confirmation: { status: 'confirmed' } }

        expect(response).to have_http_status :ok
        expect(response).to match_response_schema :email_confirmation

        expect(response.body).to include_json(
          email_confirmation: { token: email_confirmation.token, status: 'confirmed' }
        )
      end.to change { email_confirmation.reload.status }.from('open').to('confirmed')
    end

    it 'prevents a confirmed email confirmation from being reopened' do
      email_confirmation.confirmed!

      expect do
        patch :update, params: { token: email_confirmation.token,
                                 email_confirmation: { status: 'open' } }

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to include_json(errors: { status: ["can't be changed"] })
      end.not_to change { email_confirmation.reload.status }
    end

    it 'prevents an expired email confirmation from being confirmed' do
      email_confirmation.expired!

      expect do
        patch :update, params: { token: email_confirmation.token,
                                 email_confirmation: { status: 'confirmed' } }

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to include_json(errors: { status: ["can't be changed"] })
      end.not_to change { email_confirmation.reload.status }
    end
  end
end
