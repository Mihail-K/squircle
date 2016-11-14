# frozen_string_literal: true
class ParticipationLoader < Loader
  def for(conversations)
    Post.not_deleted
        .where(author: current_user, conversation: conversations)
        .group(Post.arel_table[:conversation_id])
        .count if current_user.present?
  end
end
