require_relative 'item'

module Simp::Cli::Config

  # mixin that provides common logic for safe_apply()
  module SafeApplying
    def safe_apply
      # set skip reason if we are not allowed to apply as
      # an unpriviledged user and we are not already
      # skipping for some other reason
      unless @allow_user_apply
        if ENV.fetch('USER') != 'root'
          @skip_apply = true
          @skip_apply_reason = '[**user is not root**]' unless @skip_apply_reason
        end
      end

      action = @description.split("\n")[0]

      if @skip_apply
        @applied_status = :skipped
        info( "(Skipping apply#{skip_apply_reason})", [status_color, :BOLD], " #{action}" )
      else
        info( ">> Applying:", [:GREEN, :BOLD], " #{action}... " ) # ending space prevents \n
        debug('') # add \n after 'Applying:...' when debug logging is enabled
        begin
          apply
          info( "#{@applied_status.to_s.capitalize}", [status_color, :BOLD] )
          if @applied_status == :failed
            if @die_on_apply_fail
              raise ApplyError.new(apply_summary)
            else
              # as a courtesy, pause briefly to give user time to see the
              # error message logged by derived class, before moving on
              pause(:error)
            end
          end

        # Pass up the stack exceptions that may indicate the user has
        # interrupted execution
        rescue EOFError, SignalException => e
          raise
        # Pass up the stack detected software errors or ApplyErrors
        rescue InternalError,ApplyError => e
          raise
        # Handle any other exceptions generated by the apply()
        rescue Exception => e
          @applied_status = :failed
          error( "#{@applied_status.to_s.capitalize}:", [status_color, :BOLD] )
          if @die_on_apply_fail
            # Some failures should be punished by death
            raise ApplyError.new(e.message)
          else
            error( "#{e.message.to_s.gsub( /^/, '    ' )}", [status_color] )
          end
        end
      end
      @applied_time = Time.now
    end
  end

  # A special Item that is never interactive, but applies some configuration
  class ActionItem < Item
    include Simp::Cli::Config::SafeApplying

    attr_accessor :applied_status, :applied_time, :applied_detail
    attr_accessor :skip_apply, :skip_apply_reason
    attr_accessor :die_on_apply_fail, :allow_user_apply

    def initialize
      super
      @applied_status    = :unattempted  # status of an applied change
      @applied_time      = nil           # time at which applied change completed
      @applied_detail    = nil           # details about the apply to be conveyed to user
      @skip_apply        = false         # skip the apply
      @skip_apply_reason = nil           # optional description of reason for skipping the apply
      @data_type         = :none         # carries no data
      @die_on_apply_fail = false         # halt simp config if apply fails
      @allow_user_apply  = false         # allow non-superuser to apply
    end

    # internal method to change the system (returns the result of the apply)
    def apply; nil; end

    # don't be interactive!
    def validate( x ); true; end
    def query;         nil;  end
    def print_summary; nil;  end
    def to_yaml_s;     nil;  end
  end
end
