class AddCurrentRoomToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :current_room, :integer
  end
end
