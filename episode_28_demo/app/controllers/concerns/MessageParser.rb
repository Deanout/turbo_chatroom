module MessageParser
  extend ActiveSupport::Concern

  def parse_slash_commands(message)
    should_create_message = true
    if message.body.start_with?('/')
      command = message.body.split(' ')
      role_manager(command)
      random_manager(command)
      should_create_message = status_manager(command)
      help_manager(command)
    end
    should_create_message
  end

  def role_manager(command)
    if command[0] == @role
      return unless current_user
      return unless current_user.admin?

      target_username = command[1]
      target_role = command[2]

      target_user = User.find_by(username: target_username)
      role = User.roles[target_role]

      @message.body += "Target user: #{target_user.username}, Role: #{target_role}"
      target_user.update(role:) if target_user && role
    end
  end

  def random_manager(command)
    if command[0] == @random
      lower_bound = command[1].to_i
      upper_bound = command[2].to_i
      random_number = rand(lower_bound..upper_bound)
      @message.body = "Rolled between #{lower_bound} and #{upper_bound}. Got: #{random_number}"
    end
  end

  def status_manager(command)
    case command[0]
    when @dnd
      new_status = current_user.dnd? ? User.statuses[:online] : User.statuses[:dnd]
      current_user.update(status: new_status)
    when @away
      current_user.update(status: User.statuses[:away])
    when @offline
      current_user.update(status: User.statuses[:offline])
    when @online
      current_user.update(status: User.statuses[:online])
    end
    return false
  end

  def help_manager(command)
    if command[0] == @help
      result = "\n"
      @command_options.each do |com|
        result += "\n#{com[0]} #{com[1]}\n"
      end
      @message.body += result
    end
  end

  private

  def set_commands
    @role = '/role'
    @random = '/random'
    @dnd = '/dnd'
    @away = '/away'
    @online = '/online'
    @offline = '/offline'
    @help = '/help'

    @command_options = {
      @role => '[username] [role]',
      @random => '[lower_bound] [upper_bound]',
      @dnd => 'Set your status to do not disturb',
      @away => 'Set your status to away',
      @online => 'Set your status to online',
      @offline => 'Set your status to offline',
      @help => 'Shows all commands'
    }
  end
end
