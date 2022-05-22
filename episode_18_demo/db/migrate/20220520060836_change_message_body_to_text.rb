class ChangeMessageBodyToText < ActiveRecord::Migration[7.0]
  def change
    change_column :messages, :body, :text
  end
end
