# frozen_string_literal: true

RSpec.describe Cocov::PluginKit::Run do
  let(:output) { StringIO.new }
  subject { described_class.new(output) }

  before do
    allow(ENV).to receive(:fetch).with("COCOV_WORKDIR").and_return("/tmp")
    allow(ENV).to receive(:fetch).with("COCOV_REPO_NAME").and_return("cocov-ci/dummy")
    allow(ENV).to receive(:fetch).with("COCOV_COMMIT_SHA").and_return("000000000")
  end

  it "delegates #exec to Exec#exec" do
    expect(Cocov::PluginKit::Exec).to receive(:exec).with("cmd", opts: true).and_return("output")
    expect(subject.exec("cmd", opts: true)).to eq "output"
  end

  it "delegates #exec2 to Exec#exec2" do
    expect(Cocov::PluginKit::Exec).to receive(:exec2).with("cmd", opts: true).and_return(%w[stdout stderr])
    expect(subject.exec2("cmd", opts: true)).to eq %w[stdout stderr]
  end

  context "#sha1" do
    it "calculates a sha1 digest" do
      expect(subject.sha1("Hello")).to eq "f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0"
    end
  end

  context "#emit_issue" do
    let(:opts) { { kind: :bug, file: "f", line_start: 1, line_end: 1, message: "foo" } }

    [
      ["kind", { kind: :foo },
       "Invalid kind `foo'. Valid options are style, performance, security, bug, complexity, duplication"],
      ["file type", { file: 1 }, "file must be a non-empty string"],
      ["file presence", { file: "   " }, "file must be a non-empty string"],
      ["line_start type", { line_start: "foo" }, "line_start must be an integer greater than zero"],
      ["line_start range", { line_start: 0 }, "line_start must be an integer greater than zero"],
      ["line_end type", { line_end: "foo" }, "line_end must be an integer greater than zero"],
      ["line_end range", { line_end: 0 }, "line_end must be an integer greater than zero"],
      ["message type", { message: 1 }, "message must be a non-empty string"],
      ["message presence", { message: "   " }, "message must be a non-empty string"],
      ["uid presence", { uid: "   " }, "uid must be a non-empty string when provided"],
      ["uid type", { uid: :foo }, "uid must be a non-empty string when provided"]
    ].each do |args|
      test, override, msg = args
      it "validates #{test}" do
        expect { subject.emit_issue(**opts.merge(override)) }.to raise_error(ArgumentError)
          .with_message(msg)
      end
    end

    it "emits to output when valid" do
      subject.emit_issue(**opts)
      output.rewind
      expect(output.string).to eq "{\"kind\":\"bug\",\"file\":\"f\",\"line_start\":1,\"line_end\":1,\"message\":\"foo\",\"uid\":\"3f8f97ddda0b4388bd278778f9ef07296af52c6e\"}\u0000"
    end
  end
end
