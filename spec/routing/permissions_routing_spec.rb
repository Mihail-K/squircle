# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PermissionsController, type: :routing do
  it 'has a routable index path' do
    expect(get: 'permissions').to be_routable
  end

  it 'has a routable show path' do
    expect(get: 'permissions/1').to be_routable
  end

  it 'does not have a routable create path' do
    expect(post: 'permissions').not_to be_routable
  end

  it 'does not have a routable update path' do
    expect(patch: 'permissions/1').not_to be_routable
  end

  it 'does not have a routable delete path' do
    expect(delete: 'permissions/1').not_to be_routable
  end
end
