# Oxidized Mix

This is custom Oxidized for MIXI network operation which covers both [oxidized](https://github.com/ytti/oxidized)
and [oxidized-script](https://github.com/ytti/oxidized-script).


## Concept

This gem extends Oxidized to introduce the features below. We should have upstreamed some of them and will do in the
future, use this gem until then.


## Features

### :zap: Config free

Define minimal configurations within the gem to run without a config file while the original oxidized assumes
`~/.config/oxidized/config` or something like that.

### :zap: Custom model

Include custom models within the gem to share among the team while the original oxidized assumes
`~/.config/oxidized/model/` for location.

### :zap: One-off execution

Introduce a feature to run once while the original oxidized runs as daemon.

### :zap: Store files in sub-directories

Store device config files in `[repository root]/[group name]/` while the original oxidized stores in `[repository root]/`.

### :zap: Multi-repo support

Introduce multi-repo support while the original oxidized assumes single-repo.


## Installation

Install the gem and add to the application's Gemfile by executing:

```shell
bundle add oxidized-mix --github mixigroup/oxidized-mix
bundle add oxidized-script --github ytti/oxidized-script

# or

bundle add oxidized-mix --git https://github.com/mixigroup/oxidized-mix.git
bundle add oxidized-script --git bundle add oxidized-script --github ytti/oxidized-script
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
gem install specific_install
gem specific_install https://github.com/mixigroup/oxidized-mix.git
gem specific_install https://github.com/ytti/oxidized-script.git
```

:memo: Install [oxidized-script](https://github.com/ytti/oxidized-script) manually until a newer version is released. oxidized-script `0.6.0` doesn't work along with oxidized `0.28`. See [the issue](https://github.com/ytti/oxidized-script/issues/43) for details.


## Config

Oxidized Mix requires `router.db` in the repository root, which should be looks like:

```
device1:junos:Group1
device2:eos:Group1
```


## Usage

Run `oxidized` once:

```shell
oxidized-mix --git-user "Your Name" --git-email your-email@example.com --repo your_repo_path
```

Run `oxs`:

```shell
oxs-mix --repo your_repo_path device1 "show version; show chassis hard"
```

:bulb: Original CLI options of `oxidized` and `oxs` are available.


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mixigroup/oxidized-mix.


## Copyright and License

Copyright (c) 2023 MIXI, Inc. Code released under the [MIT license](LICENSE).

### Oxidized Mix subcomponents

Oxidized Mix includes a number of subcomponents with separate copyright
notices and license terms. Your use of the source code for the these subcomponents
is subject to the terms and conditions of the following licenses.

> Copyright
> 2013-2015 Saku Ytti <saku@ytti.fi>
> 2013-2015 Samer Abdel-Hafez <sam@arahant.net>
>
> Licensed under the Apache License, Version 2.0 (the "License"); you may not use
> this file except in compliance with the License. You may obtain a copy of the
> License at
>
> http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software distributed
> under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
> CONDITIONS OF ANY KIND, either express or implied. See the License for the
> specific language governing permissions and limitations under the License.

The subcomponents are listed in [LICENSE](LICENSE).
