# Oxidized Mix

This is custom Oxidized for MIXI network operation which covers both [oxidized](https://github.com/ytti/oxidized) and [oxidized-script](https://github.com/ytti/oxidized-script).


## Concept

This gem extends Oxidized to introduce the features below. We should have upstreamed some of them and will do in the future, use this gem until then.


## Features

### :cat: Pre-defined oxidized config

Define minimal configurations within gem to share among the team while the original oxidized assumes a config file `~/.config/oxidized/config`.

### :dog: Custom model

Include custom models within the gem to share among the team while the original oxidized assumes `~/.config/oxidized/model/` for location.

### :mouse: One-off execution

Introduce a feature to run once while the original oxidized runs as daemon.

### :hamster: Store files in sub-directories

Store device config files in `[repository root]/[group name]/` while the original oxidized stores in `[repository root]/`.

### :rabbit: Multi-repo support

Introduce multi-repo support while the original oxidized assumes single-repo.


## Installation

Install the gem and add to the application's Gemfile by executing:

```
bundle add oxidized-mix
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
gem install oxidized-mix
```


## Usage

TODO: Write usage instructions here


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oxidized-mix.
