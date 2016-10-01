class AllMessagesChannel < ApplicationCable::Channel
  def subscribed
    broadcast_action('all_messages', 'online')
    stream_for "all_messages"
  end

  def unsubscribed
    broadcast_action('all_messages', 'offline')
  end

  def sendMessage
    broadcast_action('all_messages', 'sent message')
  end

  def broadcast_action(streamName, action)
    AllMessagesChannel.broadcast_to('all_messages', userId: current_user_id, msg: action)
  end
end
