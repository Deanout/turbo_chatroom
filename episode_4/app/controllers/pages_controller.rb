class PagesController < ApplicationController
  after_action :set_status
  def home
  end

  private
  def set_status
    current_user.update!(status: User.statuses[:offline]) if current_user
  end
end
