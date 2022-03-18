class AddCurrentRoomToUser < ActiveRecord::Migration[7.0]
  def change
    # add current room as integer
    add_reference :users, :current_room, integer: true
  end
end
