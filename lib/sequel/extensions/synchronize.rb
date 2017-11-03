# frozen_string_literal: true

require 'sequel/model'

module Sequel
  module Synchronize
    def synchronize_with(*args, timeout: 10.seconds, savepoint: false, key: lock_key_for(args))
      transaction(savepoint: savepoint) do
        hash = hash(key)
        get_lock(key, hash, timeout: timeout)
        Rails.logger.info("locked with #{key} (#{hash})")
        yield
      end
    end

    private

    def get_lock(key, hash, timeout:)
      Timeout.timeout(timeout) do
        self["SELECT pg_advisory_xact_lock(?) -- ?", hash, key].get
      end
    end

    def lock_key_for(args)
      args.to_a.flatten.join("-")
    end

    def hash(key)
      Digest::MD5.hexdigest(key)[0..7].hex
    end
  end

  Database.register_extension(:synchronize, Synchronize)
end
