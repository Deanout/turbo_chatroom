class CallController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:user]
  def user; end

  def create
    head :no_content
    ActionCable.server.broadcast 'SignalingServerChannel', signal_params
  end

  private

  def signal_params
    params.require(:call).permit(:type, :from, :to, :sdp, :candidate)
  end

  def set_user
    params.require(:user)
  end
end
