class Room < ApplicationRecord
  validates_uniqueness_of :name
  scope :public_rooms, -> { where(is_private: false) }
  after_update_commit { broadcast_if_public }
  has_many :messages
  has_many :participants, dependent: :destroy
  has_many :joinables, dependent: :destroy
  has_many :joined_users, through: :joinables, source: :user

  def broadcast_if_public
    broadcast_latest_message
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

  def latest_message
    messages.includes(:user).order(created_at: :desc).first
  end

  def broadcast_latest_message
    last_message = latest_message

    return unless last_message

    room_target = "room_#{id} last_message"
    user_target = "room_#{id} user_last_message"
    sender = Current.user.eql?(last_message.user) ? Current.user : last_message.user

    broadcast_update_to('rooms',
                        target: room_target,
                        partial: 'rooms/last_message',
                        locals: {
                          room: self,
                          last_message: last_message

                        })
    broadcast_update_to('rooms',
                        target: user_target,
                        partial: 'users/last_message',
                        locals: {
                          room: self,
                          last_message: last_message,
                          sender: sender
                        })
  end
end
