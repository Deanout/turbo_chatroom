module MessagesHelper
  #   def parse_at_mentions(message)
  #     message.gsub(/@([a-zA-Z0-9_]+)/) do |match|
  #       user = User.find_by(username: Regexp.last_match(1))
  #       if user
  #         view_context.link_to(match, user_path(user))
  #       else
  #         match
  #       end
  #     end
  #   end

  def parse_at_mentions(message)
    message.gsub(/@([a-zA-Z0-9_]+)/) do |match|
      user = User.find_by(username: Regexp.last_match(1))
      if user
        render_to_string partial: 'messages/user_mentions',
                         locals: {
                           mentioned_name: match,
                           user:
                         }
      else
        match
      end
    end
  end
end
