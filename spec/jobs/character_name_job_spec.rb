require 'rails_helper'

RSpec.describe CharacterNameJob, type: :job do
  let! :character do
    create :character
  end

  context 'posts' do
    let! :post do
      create :post, character: character
    end

    before :each do
      character.update(name: Faker::Pokemon.name)
    end

    it 'updates the name cached on posts' do
      expect do
        CharacterNameJob.perform_now(character.id)
      end.to change { post.reload.character_name }.to(character.name)
    end
  end
end
