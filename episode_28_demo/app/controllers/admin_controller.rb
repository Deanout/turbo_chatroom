class AdminController < ApplicationController
  def dashboard
    if current_user&.admin?
      @messages = Message.messages_this_month
    else
      redirect_to root_path
    end
  end
end
