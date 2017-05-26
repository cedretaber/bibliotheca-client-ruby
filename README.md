# BibliothecaClient

The client for [Bibliotheca](https://github.com/cedretaber/bibliotheca) the small library application.

[![Build Status](https://travis-ci.org/cedretaber/bibliotheca-client-ruby.svg?branch=master)](https://travis-ci.org/cedretaber/bibliotheca-client-ruby)
[![codecov](https://codecov.io/gh/cedretaber/bibliotheca-client-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/cedretaber/bibliotheca-client-ruby)
[![Code Climate](https://codeclimate.com/github/cedretaber/bibliotheca-client-ruby/badges/gpa.svg)](https://codeclimate.com/github/cedretaber/bibliotheca-client-ruby)
[![Issue Count](https://codeclimate.com/github/cedretaber/bibliotheca-client-ruby/badges/issue_count.svg)](https://codeclimate.com/github/cedretaber/bibliotheca-client-ruby)
[![Dependency Status](https://gemnasium.com/badges/github.com/cedretaber/bibliotheca-client-ruby.svg)](https://gemnasium.com/github.com/cedretaber/bibliotheca-client-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bibliotheca-client-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bibliotheca-client-ruby

## Usage

```
# login and create client.
token = Bibliotheca::Client.login email, password
client = Bibliotheca::Client.new token

# general api
client.book_search "awesome book"
book = client.book_detail 42
client.book_lend book.id

# admin api
client.user_index
client.user_create user
client.user_book_lend user.id, book.id

# logout
client.logout

# can't access no longer
client.book_search "awesome book"
#=> 401
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cedretaber/bibliotheca-client-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
