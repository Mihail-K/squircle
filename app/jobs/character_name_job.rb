# frozen_string_literal: true
class CharacterNameJob < ApplicationJob
  queue_as :medium

  def perform(character_id)
    character = Character.find(character_id)
    character.posts.update_all(character_name: character.name)
  end
end
