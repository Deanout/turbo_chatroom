class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'appearance_channel'
    online
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    offline
    stop_stream_from 'appearance_channel'
  end

  def online
    status = User.statuses[:online]
    broadcast_new_status(status) unless current_user.online?
  end

  def offline
    status = User.statuses[:offline]
    broadcast_new_status(status) unless current_user.offline?
  end

  def away
    status = User.statuses[:away]
    broadcast_new_status(status) unless current_user.away?
  end

  private

  def broadcast_new_status(_status)
    current_user.update(status: _status)
  end
end
