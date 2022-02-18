class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  scope :all_except, ->(user) { where.not(id: user) }
  after_create_commit { broadcast_append_to 'users' }
  has_many :messages

  has_one_attached :pfp

  after_commit :add_default_pfp, on: %i[create update]

  def pfp_thumbnail
    pfp.variant(resize_to_limit: [150, 150]).processed
  end

  def chat_pfp
    pfp.variant(resize_to_limit: [50, 50]).processed
  end

  private

  def add_default_pfp
    return if pfp.attached?

    pfp.attach(
      io: File.open(
        Rails.root.join('app', 'assets', 'images', 'default_profile.jpg')
      ),
      filename: 'default_profile.jpg',
      content_type: 'image/jpg'
    )
  end
end
