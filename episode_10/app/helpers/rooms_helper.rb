module RoomsHelper
  def search_rooms
    if params.dig(:name_search).present? && params.dig(:name_search).length > 0
      Room.public_rooms
          .where
          .not(id: current_user.joined_rooms.pluck(:id))
          .where('name ILIKE ?', "%#{params.dig(:name_search)}%")
          .order(name: :asc)
    else
      []
    end
  end
end
