class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status
  def index
    @room = Room.new
    @joined_rooms = current_user.joined_rooms

    @users = User.all_except(current_user)
    render 'index'
  end

  def show
    @single_room = Room.find(params[:id])

    @room = Room.new
    @joined_rooms = current_user.joined_rooms

    current_user.update!(current_room_id: @single_room.id)

    @message = Message.new

    pagy_messages = @single_room.messages.order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 10)
    @messages = messages.reverse

    @users = User.all_except(current_user)
    # clear name_search param
    @rooms = search_rooms
    render 'index'
  end

  def create
    @room = Room.create(name: params['room']['name'])
  end

  def search
    @rooms = search_rooms
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('search_results',
                              partial: 'rooms/search_results',
                              locals: { rooms: @rooms })
        ]
      end
    end
  end

  def leave
    @room = Room.find(params[:id])
    current_user.joined_rooms.delete(@room)
    redirect_to rooms_path
  end

  def join
    @room = Room.find(params[:id])
    current_user.joined_rooms << @room
    redirect_to @room
  end

  private

  def search_rooms
    if params.dig(:name_search).present? && params.dig(:name_search).length > 0
      Room.public_rooms
          .where('id NOT IN (?)', current_user.joined_rooms.pluck(:id))
          .where('name ILIKE ?', "%#{params[:name_search]}%")
          .order(name: :asc)
    else
      []
    end
  end

  def set_status
    current_user.update!(status: User.statuses[:online]) if current_user
  end
end
