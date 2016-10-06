class PersonalMessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user_id
  end

  def unsubscribed
  end

  def sendMessage
    broadcast_action(current_user_id, 'sent message')
  end

  def broadcast_action(_streamName, action)
    PersonalMessagesChannel.broadcast_to(current_user_id, userId: current_user_id, msg: action)
  end
end
