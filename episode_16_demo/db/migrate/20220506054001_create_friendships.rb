class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.belongs_to :user
      t.belongs_to :friend, class: 'User'
      t.boolean :confirmed, default: false
      t.boolean :pending, default: false

      t.timestamps
    end
  end
end
