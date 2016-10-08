Rails.application.routes.draw do
  get '/', to: 'application#index'
  get '/ports', to: 'application#ports'
  get '/using_rails_websocket', to: 'application#using_rails_websocket'
  get '/using_websocket', to: 'application#using_websocket'

  mount ActionCable.server => '/cable'
end
