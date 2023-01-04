# frozen_string_literal: true

RSpec.describe Cocov::PluginKit do
  subject { described_class }

  it "has a version number" do
    expect(Cocov::PluginKit::VERSION).not_to be nil
  end

  context "#run" do
    let(:output_file) do
      Tempfile.new.path.tap do |path|
        FileUtils.rm_rf path
      end
    end

    before do
      allow(ENV).to receive(:fetch).with("COCOV_WORKDIR").and_return("/tmp")
      allow(ENV).to receive(:fetch).with("COCOV_REPO_NAME").and_return("cocov-ci/dummy")
      allow(ENV).to receive(:fetch).with("COCOV_COMMIT_SHA").and_return("000000000")
      expect(ENV).to receive(:fetch).with("COCOV_OUTPUT_FILE").and_return(output_file)
    end

    after do
      FileUtils.rm_rf output_file
    end

    it "writes output to the provided path" do
      expect do
        subject.run do
          emit_issue(kind: :bug, file: "f", line_start: 1, line_end: 1, message: "boom")
        end
      end.to raise_error(SystemExit) do |error|
        expect(error.status).to eq 0
      end

      expect(File.read(output_file).to_s).to eq "{\"kind\":\"bug\",\"file\":\"f\",\"line_start\":1,\"line_end\":1,\"message\":\"boom\",\"uid\":\"ce618f566e6637885e1e33c10d092822bb8cb033\"}\u0000"
    end

    it "exits with error" do
      expect do
        subject.run do
          bla
        end
      end.to raise_error(SystemExit) do |error|
        expect(error.status).to eq 1
      end
    end
  end
end
