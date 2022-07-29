class SignalingServerChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'SignalingServerChannel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_stream_from 'SignalingServerChannel'
  end
end
