# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserDisplayNameJob, type: :job do
  let! :user do
    create :user
  end

  context 'for characters' do
    let! :character do
      create :character, user: user
    end

    before :each do
      user.update_columns(display_name: 'A different name')
    end

    it 'updates cached display names on likes' do
      expect do
        UserDisplayNameJob.perform_now(user.id)
      end.to change { character.reload.display_name }.to(user.display_name)
    end
  end

  context 'for likes' do
    let! :like do
      create :like, user: user
    end

    before :each do
      user.update_columns(display_name: 'A different name')
    end

    it 'updates cached display names on likes' do
      expect do
        UserDisplayNameJob.perform_now(user.id)
      end.to change { like.reload.display_name }.to(user.display_name)
    end
  end

  context 'for posts' do
    let! :post do
      create :post, author: user
    end

    before :each do
      user.update_columns(display_name: 'A different name')
    end

    it 'updates cached display names on posts' do
      expect do
        UserDisplayNameJob.perform_now(user.id)
      end.to change { post.reload.display_name }.to(user.display_name)
    end
  end
end
