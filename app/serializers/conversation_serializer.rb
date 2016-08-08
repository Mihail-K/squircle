class ConversationSerializer < ActiveModel::Serializer
  attribute :id
  attribute :author_id

  attribute :title
  attribute :views_count
  attribute :posts_count
  attribute :created_at
  attribute :updated_at

  belongs_to :author, serializer: UserSerializer

  has_many :post_authors, serializer: UserSerializer do
    object.post_authors.first(5)
  end
  has_many :post_characters, serializer: CharacterSerializer do
    object.post_characters.first(5)
  end

  has_one :first_post, serializer: PostSerializer
  has_one :last_post, serializer: PostSerializer
end
