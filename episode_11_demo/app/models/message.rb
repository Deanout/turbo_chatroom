class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  before_create :confirm_participant
  has_many_attached :attachments, dependent: :destroy

  after_create_commit do
    update_parent_room
    broadcast_append_to room
  end

  def chat_attachment(index)
    target = attachments[index]
    return unless attachments.attached?

    if target.image?
      target.variant(resize_to_limit: [150, 150])
    elsif target.video?
      target.variant(resize_to_limit: [150, 150])
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
end
