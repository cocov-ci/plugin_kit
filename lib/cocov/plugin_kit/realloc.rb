# frozen_string_literal: true

module Cocov
  module PluginKit
    # :nodoc:
    class Realloc
      def self.bindings
        secrets_path = Pathname.new("/secrets")
        bindings_path = secrets_path.join("bindings")
        return {} if !bindings_path.exist? || bindings_path.directory?

        bindings_path.read.split("\0").to_h do |entry|
          from, to = entry.split("=", 2)
          from_path = secrets_path.join(from)
          to_path = Pathname.new(File.expand_path(to))
          [from_path, to_path]
        end
      end

      def self.mounts!
        bindings.each do |from_path, to_path|
          unless from_path.exist?
            puts "Expected binding of #{from_path} to exist, but could not locate it"
            exit 1
          end

          to_path.dirname.mkpath

          FileUtils.cp from_path, to_path
        end
      end
    end
  end
end
