class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status
  def index
    @room = Room.new
    @rooms = Room.public_rooms

    @users = User.all_except(current_user)
    render 'index'
  end

  def show
    @single_room = Room.find(params[:id])

    @room = Room.new
    @rooms = Room.public_rooms

    @message = Message.new

    pagy_messages = @single_room.messages.order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 10)
    @messages = messages.reverse

    @users = User.all_except(current_user)
    render 'index'
  end

  def create
    @room = Room.create(name: params['room']['name'])
  end

  private

  def set_status
    current_user.update!(status: User.statuses[:online]) if current_user
  end
end
