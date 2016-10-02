# TODO

- disconnected does not work as expected with ports

types of messages

- "confirmation": "confirm_subscription",
- "rejection": "reject_subscription"
- "welcome": "welcome",
- "ping": "ping"
- else actual message

type of callbacks

- connected - tell by "confirm_subscription"
- disconnected - websocket library will tell (lowlevel)
- received message - will need a decoder
- rejected by server - "reject_subscription" equivalent to unauthorized

sending actions to server needs to match up
