class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  before_create :confirm_participant
  has_many_attached :attachments, dependent: :destroy

  validate :validate_attachment_filetypes

  after_create_commit do
    notify_recipients
    update_parent_room
    broadcast_append_later_to room
    broadcast_to_home_page
  end

  def chat_attachment(index)
    target = attachments[index]
    return unless attachments.attached?

    if target.image?
      target.variant(resize_to_limit: [150, 150]).processed
    elsif target.video?
      target.variant(resize_to_limit: [150, 150]).processed
    end
  end

  def confirm_participant
    return unless room.is_private

    is_participant = Participant.where(user_id: user.id, room_id: room.id).first
    throw :abort unless is_participant
  end

  def update_parent_room
    room.update(last_message_at: Time.now)
  end

  private

  def validate_attachment_filetypes
    return unless attachments.attached?

    attachments.each do |attachment|
      next if attachment.content_type.in?(%w[image/jpeg image/png image/gif video/mp4 video/mpeg audio/wav])

      errors.add(:attachments, 'Only jpeg, png, gif, mp4, mpeg, and wav are allowed.')
    end
  end

  def notify_recipients
    users_in_room = room.joined_users
    users_in_room.each do |user|
      next if user.eql?(self.user)

      notification = MessageNotification.with(message: self, room:)
      notification.deliver_later(user)
    end
  end

  def broadcast_to_home_page
    broadcast_prepend_later_to 'public_messages',
                               target: 'public_messages',
                               partial: 'messages/message_preview',
                               locals: { message: self }
    message_to_remove = Message.where(room: Room.public_rooms).order(created_at: :desc).fifth

    broadcast_remove_to 'public_messages',
                        target: message_to_remove
  end
end
