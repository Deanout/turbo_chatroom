class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :turbo_frame_request_variant
  before_action :set_current_user
  before_action :validate_username

  private

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def set_current_user
    Current.user = current_user
  end

  def validate_username
    return if current_user.nil?
    # return if currently on edit user page
    return if request.path.include?('/users')

    if current_user.username.blank?
      redirect_to edit_user_registration_path,
                  alert: 'Please update your username before continuing.'
    end
  end
end
