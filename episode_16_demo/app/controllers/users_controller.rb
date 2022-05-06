class UsersController < ApplicationController
  include RoomsHelper
  def show
    @user = User.find(params[:id])
    @users = User.all_except(current_user)

    @room = Room.new
    @joined_rooms = current_user.joined_rooms
    @rooms = search_rooms
    @room_name = get_name(@user, current_user)
    @single_room = Room.where(name: @room_name).first || Room.create_private_room([@user, current_user], @room_name)
    current_user.update(current_room: @single_room.id)

    @message = Message.new

    pagy_messages = @single_room.messages.includes(:user).order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 10)
    @messages = messages.reverse

    render 'rooms/index'
  end

  def friend
    @user = User.find(params[:id])

    room_name = get_name(current_user, @user)
    @single_room = Room.where(name: room_name).first || Room.create_private_room([current_user, user], room_name)
    @friend_gid = @user.to_gid_param

    if current_user.friends_with?(@user)
      current_user.remove_friend(@user, @single_room, @friend_gid)
    else
      current_user.add_friend(@user, @single_room, @friend_gid)
    end

    respond_to do |format|
      format.turbo_stream { render 'users/friend' }
    end
  end
end
