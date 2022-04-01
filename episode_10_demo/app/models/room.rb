class Room < ApplicationRecord
  validates_uniqueness_of :name
  scope :public_rooms, -> { where(is_private: false) }
  after_update_commit { broadcast_if_public }
  has_many :messages, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :joinables, dependent: :destroy
  has_many :joined_users, through: :joinables, source: :user

  def broadcast_if_public
    return if is_private

    last_message = messages.includes(:user).last

    broadcast_replace_to('rooms',
                         locals: {
                           last_message: last_message,
                           user: last_message.user,
                           room: self
                         })
  end

  def self.create_private_room(users, room_name)
    single_room = Room.create(name: room_name, is_private: true)
    users.each do |user|
      Participant.create(user_id: user.id, room_id: single_room.id)
    end
    single_room
  end

  def participant?(room, user)
    room.participants.where(user: user).exists?
  end
end
