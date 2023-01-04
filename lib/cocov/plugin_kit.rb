# frozen_string_literal: true

require "json"
require "yaml"
require "digest/sha1"
require "pathname"
require "tempfile"
require "tmpdir"

require_relative "plugin_kit/version"
require_relative "plugin_kit/run"
require_relative "plugin_kit/exec"

module Cocov
  # PluginKit implements helpers for implementing Cocov Plugins in Ruby. The
  # main module provides a single run function that must be used to wrap the
  # plugin runtime, and is responsible for preparing the environment and running
  # the provided block
  module PluginKit
    module_function

    # Public: Prepares the environment and executes a given `klass` (Class) or
    # a single block. When `klass` is not provided, PluginKit::Run is used.
    # When providing a custom class, make sure to inherit PluginKit::Run.
    # For examples, see the library's README file.
    def run(klass = nil, &block)
      output_file = File.open(ENV.fetch("COCOV_OUTPUT_FILE"), "w")
      exit_code = 0
      klass ||= Run
      instance = klass.new(output_file)
      Dir.chdir(instance.workdir) do
        if block_given?
          instance.instance_exec(&block)
        else
          instance.run
        end
      rescue SystemExit => e
        exit_code = e.status
      rescue Exception => e
        puts "Failed processing: #{e}"
        puts e.backtrace.join("\n")
        exit_code = 1
      end

      output_file.flush
      output_file.close

      exit(exit_code)
    end
  end
end
