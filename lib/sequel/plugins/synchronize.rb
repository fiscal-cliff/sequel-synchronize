# frozen_string_literal: true

module Sequel
  module Plugins
    module Plugins::Synchronize
      module ClassMethods
        def synchronize_with(*args, &block)
          db.extension(:synchronize).synchronize_with(*args, &block)
        end
      end

      module InstanceMethods
        def synchronize(*args, timeout: nil, savepoint: false)
          options = { timeout: timeout, savepoint: savepoint, key: lock_key_for(args) }
          self.class.synchronize_with(options) { yield(reload) }
        end

        private

        def lock_key_for(args)
          [self.class.table_name, self[primary_key], *args].flatten.join("-")
        end
      end
    end
  end
end
