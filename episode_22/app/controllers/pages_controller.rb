class PagesController < ApplicationController
  after_action :set_status
  before_action :recent_messages, only: [:home]

  def home
    recent_messages
    @online_users = User.where.not(status: User.statuses[:offline]).count
  end

  private

  def set_status
    current_user.update!(status: User.statuses[:offline]) if current_user
  end

  def recent_messages
    public_rooms = Room.public_rooms

    @messages = Message.where(room: public_rooms).order(created_at: :desc).limit(5)
  end
end
