# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FriendshipsController, type: :routing do
  it 'routes to #index' do
    expect(get: '/friendships').to route_to('friendships#index')
  end

  it 'routes to #index as a sub-resource of users' do
    expect(get: '/users/1/friendships').to route_to('friendships#index', user_id: '1')
  end

  it 'routes to #show' do
    expect(get: '/friendships/1').to route_to('friendships#show', id: '1')
  end

  it 'routes to #create' do
    expect(post: '/friendships').to route_to('friendships#create')
  end

  it "doesn't route to #update" do
    expect(patch: '/friendships/1').not_to be_routable
  end

  it 'routes to #destroy' do
    expect(delete: '/friendships/1').to route_to('friendships#destroy', id: '1')
  end
end
