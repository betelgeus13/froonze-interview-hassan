module Utils
  class RollbarService
    # Wrapper methods around Rollbar's methods, to log to Development console the error
    # Reason: In Devlopment, Rollbar is disabled so errors are raised and caught silently.
    def self.method_missing(message, *args, &block)
      error = args.first
      # print for development. We should not print for test
      if Rails.env.development?
        puts(error.to_s.red)
        # add support for text errors; rollbar supports errros without backtrace
        puts(error.backtrace.first(16).join("\n").to_s.red) if error.respond_to?(:backtrace) && error.backtrace.present? # Sometimes, custom errors don't have backtrace
      end
      ::Rollbar.send(message, *args, &block)
    end
  end
end
