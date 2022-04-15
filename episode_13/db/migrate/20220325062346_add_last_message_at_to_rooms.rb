class AddLastMessageAtToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :last_message_at, :datetime
  end
end
