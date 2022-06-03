class MessagesController < ApplicationController
  def create
    @message = current_user.messages.build(
      body: msg_params[:body],
      room_id: params[:room_id],
      attachments: msg_params[:attachments]
    )
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
