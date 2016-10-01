require 'securerandom'

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      @current_user_id = SecureRandom.uuid
    end
  end
end
