# frozen_string_literal: true

module Cocov
  module PluginKit
    class Run
      attr_reader :workdir, :repo_name, :commit_sha

      def initialize(output_file)
        @workdir = Pathname.new(ENV.fetch("COCOV_WORKDIR"))
        @repo_name = ENV.fetch("COCOV_REPO_NAME")
        @commit_sha = ENV.fetch("COCOV_COMMIT_SHA")

        @output_file = output_file
      end

      def run; end

      def exec2(cmd, **options)
        Exec.exec2(cmd, **options)
      end

      def exec(cmd, **options)
        Exec.exec(cmd, **options)
      end

      def sha1(data)
        Digest::SHA1.hexdigest(data)
      end

      ALLOWED_KINDS = %i[style performance security bug complexity duplication].freeze

      def emit_problem(kind:, file:, line_start:, line_end:, message:, uid: nil)
        unless ALLOWED_KINDS.include? kind
          raise ArgumentError, "Invalid kind `#{kind}'. Valid options are #{ALLOWED_KINDS.join(", ")}"
        end

        raise ArgumentError, "file must be a non-empty string" if !file.is_a?(String) || file.strip == ""

        if !line_start.is_a?(Integer) || line_start < 1
          raise ArgumentError, "line_start must be an integer greater than zero"
        end

        raise ArgumentError, "line_end must be an integer greater than zero" if !line_end.is_a?(Integer) || line_end < 1

        raise ArgumentError, "message must be a non-empty string" if !message.is_a?(String) || message.strip == ""

        if !uid.nil? && (!uid.is_a?(String) || uid.strip == "")
          raise ArgumentError, "uid must be a non-empty string when provided"
        end

        data = {
          kind: kind,
          file: file,
          line_start: line_start,
          line_end: line_end,
          message: message
        }

        uid = sha1(data.map { |k, v| [k, v].join }.join) if uid.nil?
        data[:uid] = uid

        @output_file.write("#{data.to_json}\x00")
        true
      end
    end
  end
end
