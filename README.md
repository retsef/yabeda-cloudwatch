# Yabeda::Cloudwatch

[![Gem Version](https://badge.fury.io/rb/yabeda-cloudwatch.svg)](https://rubygems.org/gems/yabeda-cloudwatch)

Adapter for easy exporting your collected metrics from your application to the [AWS Cloudwatch]!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yabeda-cloudwatch'
```

And then execute:

    $ bundle

## Usage

Add adapter to existing Yabeda config

```ruby
client = Aws::Cloudwatch::Client.new(
  credentials: Aws::Credentials.new("project_access_key_id", "project_secret_access_key"),
  region: 'eu-west-1'
)
adapter = Yabeda::Cloudwatch::Adapter.new(connection: client)
    
Yabeda.configure do
  register_adapter(:cloudwatch, adapter)
end
```

All the metrics will be sended to Amazon AWS Cloudwatch. 

At this of early release there is some chaveaut to take in mind:
1. At least one `default_tag` must be specified. All the tags is sended as metric `dimensions` and at least one should be present
2. `Counter#increment` cannot trac increment (due to cloudwatch client limitation) and `by` param will be used as total count, like `Gauge#set`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yabeda-rb/yabeda-prometheus.

### Releasing

1. Bump version number in `lib/yabeda/cloudwatch/version.rb`

   In case of pre-releases keep in mind [rubygems/rubygems#3086](https://github.com/rubygems/rubygems/issues/3086) and check version with command like `Gem::Version.new(Yabeda::Cloudwatch::VERSION).to_s`

2. Fill `CHANGELOG.md` with missing changes, add header with version and date.

3. Make a commit:

   ```sh
   git add lib/yabeda/cloudwatch/version.rb CHANGELOG.md
   version=$(ruby -r ./lib/yabeda/cloudwatch/version.rb -e "puts Gem::Version.new(Yabeda::Cloudwatch::VERSION)")
   git commit --message="${version}: " --edit
   ```

4. Create annotated tag:

   ```sh
   git tag v${version} --annotate --message="${version}: " --edit --sign
   ```

5. Fill version name into subject line and (optionally) some description (list of changes will be taken from changelog and appended automatically)

6. Push it:

   ```sh
   git push --follow-tags
   ```

7. GitHub Actions will create a new release, build and push gem into RubyGems! You're done!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[AWS Cloudwatch]: https://aws.amazon.com/ "AWS monitoring solution"