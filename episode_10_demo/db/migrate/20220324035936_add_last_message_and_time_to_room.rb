class AddLastMessageAndTimeToRoom < ActiveRecord::Migration[7.0]
  # Add two columns to rooms table
  def change
    add_column :rooms, :last_message_at, :datetime
    add_column :rooms, :last_message_id, :integer
  end
end
