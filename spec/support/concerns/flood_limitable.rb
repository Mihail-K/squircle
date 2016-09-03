require 'rails_helper'

RSpec.shared_examples_for 'flood_limitable' do
  let :model do
    controller.controller_name.singularize.camelize.constantize
  end

  let :attributes do
    attributes_for(model.model_name.name)
  end

  it 'prevents the user from making posts too frequently' do
    expect do
      post :create, format: :json, params: attributes
    end.to change { model.count }.by(1)

    expect(response).to have_http_status :created

    expect do
      post :create, format: :json, params: attributes
    end.not_to change { model.count }

    expect(response).to have_http_status :unprocessable_entity
    expect(response).to match_response_schema 'errors'

    expect(json[:errors]).to have_key :base
    expect(json[:errors][:base]).to include('you can only post once every 20 seconds')
  end
end
