class UsersController < ApplicationController
  include RoomsHelper
  include UsersHelper
  def show
    @user = User.find(params[:id])
    # TODO:
    # @user_rooms = @user.joined_rooms.order('last_message_at DESC')
    # Probably need the @users to be the list of rooms so we can sort by
    # last message. If it's users, this just doesn't work well.
    #
    # Also probably feeds into creating actual chats with users, instead
    # of it being all users. 
    @users = User.all_except(current_user)

    @room = Room.new
    @joined_rooms = current_user.joined_rooms.order('last_message_at DESC')
    @rooms = search_rooms
    @room_name = get_name(@user, current_user)
    @single_room = Room.where(name: @room_name).first || Room.create_private_room([@user, current_user], @room_name)
    current_user.update(current_room: @single_room)

    @message = Message.new

    pagy_messages = @single_room.messages.includes(:user).order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 10)
    @messages = messages.reverse

    render 'rooms/index'
  end
end
