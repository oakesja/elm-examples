class AllMessagesChannel < ApplicationCable::Channel
  def subscribed
    broadcast_action('online')
    stream_for 'all_messages'
  end

  def unsubscribed
    broadcast_action('offline')
  end

  def sendMessage
    broadcast_action('sent message')
  end

  def broadcast_action(action)
    AllMessagesChannel.broadcast_to('all_messages', userId: current_user_id, msg: action)
  end
end
