class ClientPushWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1 #if message can not come to user, drop it after 1 try
  def perform(channel, data)
    ActionCable.server.broadcast(channel, data)
  end
end