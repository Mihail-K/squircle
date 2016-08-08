class CharacterSerializer < ActiveModel::Serializer
  cache expires_in: 1.hour

  attribute :id
  attribute :user_id
  attribute :creator_id

  attribute :name
  attribute :title
  attribute :description
  attribute :posts_count
  attribute :created_at

  attribute :avatar_url do
    object.avatar.url
  end
  attribute :gallery_image_urls do
    object.gallery_images.map(&:url)
  end

  belongs_to :user
  belongs_to :creator, serializer: UserSerializer

  has_many :recent_posts, serializer: PostSerializer do
    object.posts.last(3)
  end
end
