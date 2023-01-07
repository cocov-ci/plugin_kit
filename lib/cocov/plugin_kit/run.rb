# frozen_string_literal: true

module Cocov
  module PluginKit
    # Public: Run implements helpers and prepares the environment for a Plugin
    # runtime. All Cocov Ruby plugins must either inherit this class or directly
    # use it by using the block alternative of Cocov::PluginKit#run.
    #
    # The class provides the following accessors:
    # - workdir:    The path to the root of the repository being checked. The
    #               plugin is always executed with its pwd set to this path.
    # - repo_name:  The name of the repository being cheked.
    # - commit_sha: The SHA of the commit being checked.
    #
    class Run
      attr_reader :workdir, :repo_name, :commit_sha

      def initialize(output_file)
        @workdir = Pathname.new(ENV.fetch("COCOV_WORKDIR"))
        @repo_name = ENV.fetch("COCOV_REPO_NAME")
        @commit_sha = ENV.fetch("COCOV_COMMIT_SHA")

        @output_file = output_file
      end

      # Public: When inheriting this class, the plugin entrypoint must be
      # implemented on this method's override.
      def run; end

      # Public: Alias to Exec.exec2. For more information, see the documentation
      # for that method.
      def exec2(cmd, **options)
        Exec.exec2(cmd, **options)
      end

      # Public: Alias to Exec.exec. For more information, see the documentation
      # for that method.
      def exec(cmd, **options)
        Exec.exec(cmd, **options)
      end

      # Public: Returns the SHA1 digest of the provided data
      def sha1(data)
        Digest::SHA1.hexdigest(data)
      end

      # :nodoc:
      ALLOWED_KINDS = %i[style performance security bug complexity duplication convention quality].freeze

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # :nodoc:
      def validate_issue_args!(kind:, file:, line_start:, line_end:, message:, uid:)
        unless ALLOWED_KINDS.include? kind
          raise ArgumentError, "Invalid kind `#{kind}'. Valid options are #{ALLOWED_KINDS.join(", ")}"
        end

        raise ArgumentError, "file must be a non-empty string" if !file.is_a?(String) || file.strip == ""

        if !line_start.is_a?(Integer) || line_start < 1
          raise ArgumentError, "line_start must be an integer greater than zero"
        end

        raise ArgumentError, "line_end must be an integer greater than zero" if !line_end.is_a?(Integer) || line_end < 1

        raise ArgumentError, "message must be a non-empty string" if !message.is_a?(String) || message.strip == ""

        return unless !uid.nil? && (!uid.is_a?(String) || uid.strip == "")

        raise ArgumentError, "uid must be a non-empty string when provided"
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Public: Emits a new issue with the provided arguments.
      #
      # kind:       - A symbol identifying kind of the issue being emitted.
      # file:       - The path, relative to the repository root, of the file
      #               where the issue was found.
      # line_start: - The first line where the issue was found. Must be greater
      #               than zero.
      # line_end:   - The last line where the issue was found. Must be equal or
      #               greater than the value of line_start.
      # message:    - A message describing the issue. Must not be empty.
      # uid:        - An uniquely identifier representing this issue among any
      #               other possible issue in any other file in this repository.
      #               This identifier must be the result of a pure function;
      #               i.e. the same issue in the same file, spanning the same
      #               lines must have the same uid no matter how many times it
      #               is reported. If omitted, an UID is automatically
      #               calculated. If provided, must be a non-empty string.
      #
      # Returns nothing. Raises ArgumentError in case invalid data is provided
      # (see documentation above.)
      def emit_issue(kind:, file:, line_start:, line_end:, message:, uid: nil)
        validate_issue_args! kind: kind, file: file, line_start: line_start,
                             line_end: line_end, message: message, uid: uid
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
