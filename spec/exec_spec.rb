# frozen_string_literal: true

RSpec.describe Cocov::PluginKit::Exec do
  subject { described_class }
  let(:helper_path) { "#{File.expand_path(".")}/support/exec_helper" }

  context "#exec2" do
    it "returns stdout and stderr" do
      stdout, stderr = subject.exec2("#{helper_path} --foo --bar --baz",
                                     env: { EXEC_HELPER_TEST: true, PATH: ENV.fetch("PATH", nil) },
                                     isolate_env: true,
                                     chdir: "/tmp")

      out = JSON.parse(stdout)
      err = JSON.parse(stderr)
      expect(out["args"]).to eq ["--foo", "--bar", "--baz"]
      expect(out["pwd"]).to eq "/tmp"
      expect(out["env"]["EXEC_HELPER_TEST"]).to eq "true"
      expect(out["env"]).to have_key "PATH"
      expect(out["env"].keys).to eq %w[EXEC_HELPER_TEST PATH]
      expect(err).to eq({ "stderr" => true })
    end

    it "raises an ExecutionError in case the process fails" do
      env = { PATH: ENV.fetch("PATH", nil) }
      expect do
        subject.exec2("#{helper_path} --foo --bar --baz --fail",
                      env: env,
                      chdir: "/tmp")
      end.to raise_error(an_instance_of(Cocov::PluginKit::Exec::ExecutionError)
        .and(having_attributes(
               env: env.to_h { |*a| a.map(&:to_s) },
               cmd: "#{helper_path} --foo --bar --baz --fail",
               status: 1,
               stdout: "{\"args\":[\"--foo\",\"--bar\",\"--baz\",\"--fail\"],\"pwd\":\"/tmp\"}\n",
               stderr: "{\"stderr\":true}\n"
             )))
    end
  end

  context "#exec" do
    it "returns stdout and stderr" do
      stdout = subject.exec("#{helper_path} --foo --bar --baz",
                            env: { EXEC_HELPER_TEST: true, PATH: ENV.fetch("PATH", nil) },
                            chdir: "/tmp")

      out = JSON.parse(stdout)
      expect(out["args"]).to eq ["--foo", "--bar", "--baz"]
      expect(out["pwd"]).to eq "/tmp"
      expect(out["env"]["EXEC_HELPER_TEST"]).to eq "true"
      expect(out["env"]).to have_key "PATH"
    end
  end
end
