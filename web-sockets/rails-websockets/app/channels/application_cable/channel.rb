module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def current_user_id
      @connection.current_user_id
    end
  end
end
