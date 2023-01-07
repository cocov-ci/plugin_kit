# frozen_string_literal: true

RSpec.describe Cocov::PluginKit::Realloc do
  subject { described_class }

  describe "bindings" do
    let(:fake_secrets) { double(:fake_secrets) }
    let(:fake_bindings) { double(:fake_bindings) }
    before do
      allow(Pathname).to receive(:new).with(anything).and_call_original
      allow(Pathname).to receive(:new).with("/secrets").and_return(fake_secrets)
      allow(fake_secrets).to receive(:join).with(anything) do |path|
        path == "bindings" ? fake_bindings : path
      end
    end

    it "returns an empty hash when bindings does not exits" do
      allow(fake_bindings).to receive(:exist?).and_return(false)
      expect(subject.bindings).to be_empty
    end

    it "returns an empty hash if bindings is a directory" do
      allow(fake_bindings).to receive(:exist?).and_return(true)
      allow(fake_bindings).to receive(:directory?).and_return(true)
      expect(subject.bindings).to be_empty
    end

    it "returns and parses bindings when it exists" do
      allow(fake_bindings).to receive(:exist?).and_return(true)
      allow(fake_bindings).to receive(:directory?).and_return(false)
      allow(fake_bindings).to receive(:read).and_return("foo=bar\0bar=fnord")
      bindings = subject.bindings
      expect(bindings).not_to be_empty
      expect(bindings.to_h { |k, v| [k, v].map(&:to_s) }).to eq({
        "bar" => "/app/fnord",
        "foo" => "/app/bar"
      })
    end
  end
end
