class User < ApplicationRecord
  include RoomsHelper

  attr_accessor :user_gid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  scope :all_except, ->(user) { where.not(id: user) }
  after_create_commit { broadcast_append_to 'users' }
  after_update_commit { broadcast_update }
  has_many :messages
  has_one_attached :avatar
  has_many :joinables, dependent: :destroy
  has_many :joined_rooms, through: :joinables, source: :room
  has_many :notifications, dependent: :destroy, as: :recipient

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships

  enum role: %i[user admin]
  enum status: %i[offline away online]

  after_commit :add_default_avatar, on: %i[create update]

  after_initialize :set_default_role, if: :new_record?

  def avatar_thumbnail
    avatar.variant(resize_to_limit: [150, 150]).processed
  end

  def chat_avatar
    avatar.variant(resize_to_limit: [50, 50]).processed
  end

  def broadcast_update
    # broadcast_replace_to 'user_status', partial: 'users/status', user: self
  end

  def has_joined_room(room)
    joined_rooms.include?(room)
  end

  def status_to_css
    case status
    when 'online'
      'bg-success'
    when 'away'
      'bg-warning'
    when 'offline'
      'bg-dark'
    else
      'bg-dark'
    end
  end

  def friends_with?(user)
    friends.include?(user) && confirmed_friends(user)
  end

  def confirmed_friends(user)
    friendships.find_by(friend: user).confirmed
  end

  # check if friend request pending, return if user already sent friend request
  def friend_request_pending(user)
    friendships.find_by(friend: user).pending
  end

  def add_friend(user, room, target_gid)
    return if user == self
    return if friends_with?(user)
    return if friend_request_pending(user)

    transaction do
      friendships.create(friend: user)
      friendships.find_by(friend: user).update(confirmed: true, pending: false)
    end
    broadcast_friend_change(user, room, target_gid)
  end

  def remove_friend(user, room, target_gid)
    return if user == self
    return unless friends_with?(user)

    transaction do
      friendships.find_by(friend: user).destroy
    end
    broadcast_friend_change(user, room, target_gid)
  end

  private

  def add_default_avatar
    return if avatar.attached?

    avatar.attach(
      io: File.open(Rails.root.join('app', 'assets', 'images', 'default_profile.jpg')),
      filename: 'default_profile.jpg',
      content_type: 'image/jpg'
    )
  end

  def set_default_role
    self.role ||= :user
  end

  def broadcast_friend_change(user, single_room, target_gid)
    broadcast_replace_to(target_gid,
                         target: "user_list_#{id}",
                         partial: 'users/user',
                         locals: {
                           room: single_room,
                           user: self,
                           last_message: single_room&.latest_message,
                           sender: single_room&.latest_message&.user,
                           requestor: user
                         })
  end
end
