class MessagesController < ApplicationController
  def create
    @message = current_user.messages.create(
      body: msg_params[:body],
      room_id: params[:room_id],
      attachments: msg_params[:attachments]
    )
    if @message.save
      render json: @message, status: :created
    else
      render turbo_stream:
        turbo_stream.update('flash',
                            partial: 'shared/message_error',
                            locals: {
                              message: @message.errors.full_messages.join(', ')
                            })
    end
  end

  private

  def msg_params
    params.require(:message).permit(:body, attachments: [])
  end
end
