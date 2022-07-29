class MessagesController < ApplicationController
  include MessagesHelper
  include MessageParser

  before_action :set_commands
  def create
    @message = Message.new(
      body: msg_params[:body],
      room_id: params[:room_id],
      attachments: msg_params[:attachments],
      user_id: current_user.id
    )

    @message.body = parse_at_mentions(@message.body)
    should_create_message = parse_slash_commands(@message)

    return unless should_create_message

    unless @message.save
      render turbo_stream:
        turbo_stream.update('message_error',
                            partial: 'shared/message_error',
                            locals: { message: @message.errors.full_messages.join(', ') })
    end
  end

  private

  def msg_params
    params.require(:message).permit(:body, attachments: [])
  end
end
