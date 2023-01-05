# PluginKit

PluginKit implements a utility library to help the development of Cocov Plugins using the Ruby programming language.

## Installation

Cocov plugins should not contain Gemfiles. Instead, install the library directly
using the `gem install` command, providing a specific version. For instance,

```
gem install cocov_plugin_kit -v 0.1.2
```

## Usage

### For simple plugins

When implementing simple plugins, like for example, [brakeman](https://github.com/cocov-ci/brakeman/blob/master/plugin.rb),
the block-based usage of PluginKit can be used:

```ruby
Cocov::PluginKit.run do
  output = JSON.parse(exec(["my", "plugin", "--format", "json"], env: ENV))
  # Process output...
  emit_issue kind: # ...
end
```

### For elaborate plugins

For plugins requiring more organization or several internal methods, like [rubocop](https://github.com/cocov-ci/rubocop/blob/master/plugin.rb),
`Cocov::PluginKit::Run` can be inherited into a new class, and `#run` can be
overridden to be used as the plugin entrypoint, followed by a call to
`Cocov::PluginKit.run`:

```ruby
class ElaboratePlugin < Cocov::PluginKit::Run
  def run
    output = JSON.parse(exec(["my", "plugin", "--format", "json"], env: ENV))
    # Process output...
    emit_issue kind: # ...
  end
end

Cocov::PluginKit.run(ElaboratePlugin)
```

## Development

A `docker-compose.yaml` is provided for allowing Ruby 2.6 to be used without
requiring developers to install that version on their machines. When writing
Dockerfiles, developers are advised to use the latest version available when
building plugins.

Use `docker compose run --rm -it ruby bash` to get a shell on the container;
`bin/setup` can be used to install dependencies, `rspec` to run tests,
`rubocop` to lint the codebase, and `bin/console` to get an interactive console
that allows you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cocov-ci/plugin_kit.
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Cocov's code of conduct](https://github.com/cocov-ci/.github/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Cocov project's codebases, issue trackers, chat rooms
and mailing lists is expected to follow the [Cocov's code of conduct](https://github.com/cocov-ci/.github/blob/main/CODE_OF_CONDUCT.md).
