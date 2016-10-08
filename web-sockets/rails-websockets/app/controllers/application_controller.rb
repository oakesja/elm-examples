class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    render :index
  end

  def using_rails_websocket
    render :using_rails_websocket
  end

  def using_websocket
    render :using_websocket
  end

  def ports
    render :ports
  end
end
