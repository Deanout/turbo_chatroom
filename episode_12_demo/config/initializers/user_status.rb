module Turbochat
  class UserStatus < Application
    config.after_initialize do
      connection = ActiveRecord::Base.connection
      if connection.table_exists?('users') && connection.column_exists?('users', 'status')
        User.update_all(status: User.statuses[:offline])
      end
    rescue StandardError
      puts 'User statuses not updated'
    end
  end
end
