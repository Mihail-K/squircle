# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IndicesController, type: :controller do
  before :each do
    Index.__elasticsearch__.create_index!
  end

  after :each do
    Index.__elasticsearch__.delete_index!
  end

  describe '#GET index' do
    let! :indices do
      create_list :index, 3
    end

    let :query do
      indices.sample.primary.sample.split(' ').sample
    end

    before :each do
      Index.__elasticsearch__.client.indices.flush
    end

    it 'returns a list of indices' do
      get :index

      expect(response).to have_http_status :ok
    end

    it 'returns relevant indices' do
      get :index, params: { query: query }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(meta: { size: /[1-3]/ })
    end
  end
end
