# frozen_string_literal: true
class LikeLoader < Loader
  def for(likeables)
    Like.where(likeable: likeables).preview.group_by { |like| [like.likeable_id, like.likeable_type] }
  end
end
