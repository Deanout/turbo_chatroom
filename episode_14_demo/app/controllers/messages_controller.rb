class MessagesController < ApplicationController
  def create
    @message = current_user.messages.create(
      body: msg_params[:body],
      room_id: params[:room_id],
      attachments: msg_params[:attachments]
    )
    check_mention
  end

  # Check if message contains @ mention of user email
  def check_mention
    @message = Message.find(params[:id])
    @mention = @message.body.match(/@\w+/)

    if @mention
      @mention = @mention.to_s.gsub('@', '')
      @user = User.find_by(email: @mention)
      if @user
        @user.notifications.create(
          message: @message,
          user_id: @user.id
        )
      end
    end
  end

  private

  def msg_params
    params.require(:message).permit(:body, attachments: [])
  end
end
