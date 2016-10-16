# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Role, type: :model do
  let :role do
    build :role
  end

  it 'has a valid factory' do
    expect(role).to be_valid
  end

  it 'is not valid without a name' do
    role.name = nil
    expect(role).not_to be_valid
  end

  it 'is not valid with a duplicate name' do
    create :role, name: role.name
    expect(role).not_to be_valid
  end

  describe 'user' do
    let :role do
      Role.find_by name: 'user'
    end

    it 'exists' do
      expect(role).to be_present
    end

    it 'is allowed to view owned bans' do
      expect(role).to be_allowed_to :view_owned_bans
    end

    it 'is not allowed to view others bans' do
      expect(role).not_to be_allowed_to :view_bans
    end

    it 'is not allowed to create bans' do
      expect(role).not_to be_allowed_to :create_bans
    end

    it 'is not allowed to update bans' do
      expect(role).not_to be_allowed_to :update_bans
    end

    it 'is not allowed to delete bans' do
      expect(role).not_to be_allowed_to :delete_bans
    end

    it 'is allowed to view characters' do
      expect(role).to be_allowed_to :view_characters
    end

    it 'is not allowed to view deleted characters' do
      expect(role).not_to be_allowed_to :view_deleted_characters
    end

    it 'is allowed to create characters' do
      expect(role).to be_allowed_to :create_characters
    end

    it 'is allowed to update owned characters' do
      expect(role).to be_allowed_to :update_owned_characters
    end

    it 'is not allowed to update other characters' do
      expect(role).not_to be_allowed_to :update_characters
    end

    it 'is allowed to delete owned characters' do
      expect(role).to be_allowed_to :delete_owned_characters
    end

    it 'is not allowed to delete other characters' do
      expect(role).not_to be_allowed_to :delete_characters
    end

    it 'is allowed to view conversations' do
      expect(role).to be_allowed_to :view_conversations
    end

    it 'is not allowed to view deleted conversations' do
      expect(role).not_to be_allowed_to :view_deleted_conversations
    end

    it 'is allowed to create conversations' do
      expect(role).to be_allowed_to :create_conversations
    end

    it 'is allowed to update owned conversations' do
      expect(role).to be_allowed_to :update_owned_conversations
    end

    it 'is not allowed to update conversations' do
      expect(role).not_to be_allowed_to :update_conversations
    end

    it 'is not allowed to delete owned conversations' do
      expect(role).not_to be_allowed_to :delete_owned_conversations
    end

    it 'is allowed to view posts' do
      expect(role).to be_allowed_to :view_posts
    end

    it 'is not allowed to view deleted posts' do
      expect(role).not_to be_allowed_to :view_deleted_posts
    end

    it 'is allowed to create posts' do
      expect(role).to be_allowed_to :create_posts
    end

    it 'is allowed to edit owned posts' do
      expect(role).to be_allowed_to :update_owned_posts
    end

    it 'is not allowed to edit others posts' do
      expect(role).not_to be_allowed_to :update_posts
    end

    it 'is allowed to delete owned posts' do
      expect(role).to be_allowed_to :delete_owned_posts
    end

    it 'is not allowed to delete others posts' do
      expect(role).not_to be_allowed_to :delete_posts
    end
  end

  describe 'moderator' do
    let :role do
      Role.find_by(name: 'moderator')
    end

    it 'exists' do
      expect(role).to be_present
    end

    it 'is allowed to update all conversations' do
      expect(role).to be_allowed_to :update_conversations
    end

    it 'is allowed to delete all conversations' do
      expect(role).to be_allowed_to :delete_conversations
    end
  end

  describe 'admin' do
    let :role do
      Role.find_by name: 'admin'
    end

    it 'exists' do
      expect(role).to be_present
    end

    it 'is allowed to update bans' do
      expect(role).to be_allowed_to :update_bans
    end
  end

  describe 'banned' do
    let :role do
      Role.find_by name: 'banned'
    end

    it 'exists' do
      expect(role).to be_present
    end

    it 'is not forbidden to view owned bans' do
      expect(role).not_to be_forbidden_to :view_owned_bans
    end

    it 'is forbidden to create bans' do
      expect(role).to be_forbidden_to :create_bans
    end

    it 'is forbidden to update bans' do
      expect(role).to be_forbidden_to :update_bans
    end

    it 'is forbidden to delete bans' do
      expect(role).to be_forbidden_to :delete_bans
    end

    it 'is forbidden to create characters' do
      expect(role).to be_forbidden_to :create_characters
    end

    it 'is forbidden to update characters' do
      expect(role).to be_forbidden_to :update_characters
    end

    it 'is forbidden to delete characters' do
      expect(role).to be_forbidden_to :delete_characters
    end

    it 'is forbidden to create new conversations' do
      expect(role).to be_forbidden_to :create_conversations
    end

    it 'is forbidden to update conversations' do
      expect(role).to be_forbidden_to :update_conversations
    end

    it 'is forbidden to delete conversations' do
      expect(role).to be_forbidden_to :delete_conversations
    end

    it 'is forbidden to make new posts' do
      expect(role).to be_forbidden_to :create_posts
    end

    it 'is forbidden to edit posts' do
      expect(role).to be_forbidden_to :update_posts
    end

    it 'is forbidden to delete posts' do
      expect(role).to be_forbidden_to :delete_posts
    end
  end
end
