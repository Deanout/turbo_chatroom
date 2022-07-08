class MessagesController < ApplicationController
  include MessagesHelper
  before_action :set_commands
  def create
    @message = current_user.messages.build(
      body: msg_params[:body],
      room_id: params[:room_id],
      attachments: msg_params[:attachments]
    )

    @message.body = parse_at_mentions(@message.body)
    parse_slash_commands(@message)

    unless @message.save
      render turbo_stream:
        turbo_stream.update('message_error',
                            partial: 'shared/message_error',
                            locals: { message: @message.errors.full_messages.join(', ') })
    end
  end

  def parse_slash_commands(message)
    if message.body.start_with?('/')
      command = message.body.split(' ')
      role_manager(command)
      random_manager(command)
      help_manager(command)
    end
  end

  def role_manager(command)
    if command[0] == @role
      return unless current_user

      target_user = User.find_by(username: command[1])
      role = User.roles[command[2]]
      @message.body += "Target user: #{target_user.username}, Role: #{role}"
      target_user.update(role:) if target_user && role
    end
  end

  # replace the body of the @message with a random number
  def random_manager(command)
    if command[0] == @random
      lower_bound = command[1].to_i
      upper_bound = command[2].to_i
      random_number = rand(lower_bound..upper_bound)
      @message.body = "Rolled between #{lower_bound} and #{upper_bound}. Got: #{random_number}"
    end
  end

  # return the help message containing each command
  def help_manager(command)
    if command[0] == @help
      result = "\n"
      @command_options.each do |com|
        result += "\n#{com[0]} #{com[1]}\n"
      end
    end

    @message.body += result
  end

  private

  def set_commands
    @role = '/role'
    @random = '/random'
    @help = '/help'
    @command_options = {
      @role => '[username] [role]',
      @random => '[lower_bound] [upper_bound]',
      @help => '[command]'
    }
  end

  def msg_params
    params.require(:message).permit(:body, attachments: [])
  end
end
