class AllMessagesChannel < ApplicationCable::Channel
  def subscribed
    broadcast_action('online')
    stream_for 'all_messages'
  end

  def unsubscribed
    broadcast_action('offline')
  end

  def sendMessage(data)
    broadcast_action('sent message', data['msg'])
  end

  def broadcast_action(action, msg = '')
    AllMessagesChannel.broadcast_to(
      'all_messages',
      userId: @connection.current_user_id,
      action: action,
      msg: msg
    )
  end
end
