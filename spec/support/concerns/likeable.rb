# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples_for Likeable do
  let :likeable do
    create described_class.model_name.singular
  end

  it 'can have likes' do
    create :like, likeable: likeable
  end

  describe '.likes_count' do
    it 'increases when a like is created' do
      expect do
        create :like, likeable: likeable
      end.to change { likeable.likes_count }.by(1)
    end

    it 'decreases when a like is destroyed' do
      like = create :like, likeable: likeable

      expect do
        like.destroy
      end.to change { likeable.likes_count }.by(-1)
    end
  end
end
