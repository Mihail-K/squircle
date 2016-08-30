require 'rails_helper'

RSpec.describe SectionsController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :sections do
      create_list :section, Faker::Number.between(1, 3)
    end

    it 'returns a list of sections' do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :sections
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to eq sections.count
    end
  end
end
