# frozen_string_literal: true

module Cocov
  module PluginKit
    # Exec provides utilities for executing processes and obtaining its results.
    module Exec
      # ExecutionError is thrown when an #exec or #exec2 procedure fails. It
      # includes the captured stdout and stderr streams, along with the exit
      # status, the original command and its environment.
      class ExecutionError < StandardError
        attr_reader :stdout, :stderr, :status, :cmd, :env

        # Internal: Initializes a new ExecutionError instance
        def initialize(status, stdout, stderr, cmd, env)
          super("Process #{cmd.split.first} exited with status #{status}: #{stdout}\n#{stderr}")
          @status = status
          @stdout = stdout
          @stderr = stderr
          @cmd = cmd
          @env = env
        end
      end

      module_function

      # Public: Executes a given command (represented as an array of strings),
      # returning both its stdout and stderr streams as Strings. Extra options
      # are passed directly to Process.spawn, except:
      # -         env: when provided must be a Hash representing environment
      #                keys and values.
      # - isolate_env: Prevents the current ENV from being copied into the new
      #                process. Just a fancier name to :unsetenv_others
      # This function will block until the process finishes, either returning
      # both streams (stdout, stderr) as an Array, or raising an ExecutionError.
      #
      # Example:
      #
      #   stdout, stderr = Exec::exec2(["git", "version"], chdir: "/tmp")
      #   # stdout == "git version 2.30.2\n"
      #   # stderr == ""
      #
      def exec2(cmd, **options)
        out_reader, out_writer = IO.pipe
        err_reader, err_writer = IO.pipe

        isolate = options.delete(:isolate_env) == true
        env = (options.delete(:env) || {}).to_h { |*a| a.map(&:to_s) }
        options.delete(:chdir) if options.fetch(:chdir, nil).nil?

        opts = {
          unsetenv_others: isolate,
          out: out_writer.fileno,
          err: err_writer.fileno
        }.merge options
        pid = Process.spawn(env, cmd, **opts)

        mut = Mutex.new
        cond = ConditionVariable.new

        status = nil
        Thread.new do
          _pid, status = Process.wait2(pid)
          mut.synchronize { cond.signal }
        end

        out_writer.close
        err_writer.close

        stdout = nil
        stderr = nil
        out_thread = Thread.new { stdout = out_reader.read }
        err_thread = Thread.new { stderr = err_reader.read }
        mut.synchronize { cond.wait(mut, 0.1) } while status.nil?

        out_thread.join
        err_thread.join

        out_reader.close
        err_writer.close
        err_reader.close

        raise ExecutionError.new(status.exitstatus, stdout, stderr, cmd, env) unless status.success?

        [stdout, stderr]
      end

      # Public: exec works exactly like #exec2, but only returns the stdout
      # stream, instead of both stdout and stderr.
      # For more information, see the documentation for #exec.
      def exec(cmd, **options)
        exec2(cmd, **options).first
      end
    end
  end
end
