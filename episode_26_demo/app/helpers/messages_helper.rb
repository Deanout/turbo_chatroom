module MessagesHelper
  def parse_at_mentions(message_body)
    message_body.gsub(/@([a-zA-Z0-9_]+)/) do |match|
      user = User.find_by(username: Regexp.last_match(1))
      if user
        view_context.link_to(match, user_path(user), class: "msg-role-#{user.role}")
      else
        match
      end
    end
  end
end
