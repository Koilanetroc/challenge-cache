# frozen_string_literal: true

class RedlockManager
  def self.current
    @@instance ||= Redlock::Client.new([
      ENV["REDIS_URL"]
    ])

    @@instance
  end
end
