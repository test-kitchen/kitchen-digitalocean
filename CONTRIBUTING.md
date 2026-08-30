# Contributing

Pull requests are very welcome.

* Source is hosted on [GitHub](https://github.com/test-kitchen/kitchen-digitalocean).
* Report issues and feature requests on [GitHub Issues](https://github.com/test-kitchen/kitchen-digitalocean/issues).
* Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting set up

```bash
git clone https://github.com/test-kitchen/kitchen-digitalocean.git
cd kitchen-digitalocean
bundle install
```

You do not need a DigitalOcean account or an API token to work on this driver.
The test suite never talks to the network.

## Rake tasks

| Command | What it does |
| --- | --- |
| `bundle exec rake` | Run tests and style. The same gates CI applies. |
| `bundle exec rake test` | Run the unit tests. |
| `bundle exec rake style` | Run Cookstyle/Chefstyle. |
| `bundle exec rake style:auto_correct` | Fix the style offences that can be fixed automatically. |
| `bundle exec rake yard` | Build the API documentation into `doc/`. |
| `bundle exec rake yard:stats` | Report which objects are missing documentation. |
| `bundle exec rake yard:server` | Browse the documentation at `http://localhost:8808`. |

Run a single file or example while you iterate:

```bash
bundle exec rspec spec/kitchen/driver/digitalocean_spec.rb
bundle exec rspec spec/kitchen/driver/digitalocean_spec.rb:142
```

## How the tests work

The suite is entirely offline. Every DigitalOcean API call is stubbed with
[WebMock](https://github.com/bblimke/webmock), and `WebMock.disable_net_connect!`
turns an unstubbed request into a failure rather than letting it reach the
network. The suite never creates a Droplet and never needs credentials.

```text
spec/
├── kitchen/driver/
│   ├── digitalocean_spec.rb          the driver
│   └── digitalocean_version_spec.rb  the version constant
├── readme_spec.rb                    keeps README tables in sync with the code
├── spec_helper.rb                    RSpec and WebMock configuration
└── support/
    ├── digitalocean_api.rb           API payload builders and request stubs
    └── kitchen_helpers.rb            builds a driver the way Test Kitchen does
```

Three conventions are worth knowing before you add a test.

### Build the driver with `build_driver`

`build_driver` runs the real `finalize_config!` lifecycle hook rather than
stubbing `Kitchen::Driver::Base#instance`, so `required_config` validation and
the lazy `default_config` blocks stay on the code path under test:

```ruby
driver = build_driver(region: "lon1", size: "s-2vcpu-4gb")
```

It also defaults `server_wait_interval` to `0`, which is why the suite finishes
in under a second despite exercising both polling loops. Pass a custom instance
as the second argument when the platform or instance name matters:

```ruby
driver = build_driver({}, kitchen_instance(platform: "debian-13"))
```

Both arguments are positional on purpose. A keyword parameter would make Ruby
bind `build_driver(username: "admin")` to the keyword instead of to the config
hash.

### Build API payloads, do not record them

`spec/support/digitalocean_api.rb` builds responses in code so an example can
describe exactly the state it needs:

```ruby
stub_droplet_create
stub_droplet_find(droplets: [
  droplet_payload(status: "new", networks: :none),
  droplet_payload(status: "active", networks: :public),
])
```

Passing several payloads to `stub_droplet_find` describes a Droplet that changes
between polls, which is how the waiting behaviour is tested. `networks:` accepts
`:public`, `:private_only`, `:none` and `:absent`.

Assert on the request as well as the response where it matters:

```ruby
expect(WebMock).to have_requested(:post, "#{DigitalOceanAPI::API_ROOT}/v2/droplets")
  .with(body: hash_including(size: "s-2vcpu-4gb"))
```

### Do not leak environment variables

The driver reads several settings from the environment. `spec_helper.rb`
snapshots and restores `ENV` around every example, so set what you need inline
and let the hook clean up:

```ruby
it "reads the region from DIGITALOCEAN_REGION" do
  ENV["DIGITALOCEAN_REGION"] = "tor1"

  expect(build_driver({})[:region]).to eq("tor1")
end
```

The suite runs in random order and must pass at any seed. If a change makes it
order dependent, `bundle exec rspec --seed 1234` will usually surface it.

## Documentation

Every method, constant and module carries YARD tags, and `yard stats` reports
100% documented. If you add a method, document it:

```ruby
# Looks a Droplet up by ID, treating "not found" as a normal outcome.
#
# @param server_id [String, Integer] ID of the Droplet to fetch
# @return [DropletKit::Droplet, nil] the Droplet, or nil if it no longer exists
# @raise [Kitchen::ActionFailed] for any API error other than a 404
def find_droplet(server_id)
```

Documentation is deliberately **not** a CI gate — a missing tag should never turn
a pull request red. Check it locally instead:

```bash
bundle exec rake yard:stats
```

YARD lives in the `development` bundler group, which CI excludes. If it is not
installed, `rake yard` explains how to get it and the rest of the tasks carry on
working.

## Adding a platform slug

`PLATFORM_SLUG_MAP` in `lib/kitchen/driver/digitalocean.rb` maps short platform
names onto DigitalOcean image slugs. Add the entry there and add the matching row
to the table in the README — `spec/readme_spec.rb` fails if the two disagree, so
this cannot drift silently. Adding a mapping is a `feat:` change.

Nothing needs to be added for a slug to work at all: an unmapped platform name is
passed to the API untouched.

## Style

```bash
bundle exec rake style
```

CI runs `cookstyle --chefstyle`. `spec/` is excluded from style checks, so
expressive test code is fine.

## Commit messages and releases

Releases are automated with
[release-please](https://github.com/googleapis/release-please), which builds the
changelog and picks the next version from commit messages. Use
[Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Use it for | Version bump |
| --- | --- | --- |
| `fix:` | A bug fix | patch |
| `feat:` | A new setting or capability | minor |
| `docs:` | Documentation only | none |
| `test:` | Tests only | none |
| `chore:`, `ci:` | Tooling and CI | none |

A breaking change gets a `!` after the prefix (`feat!:`) or a
`BREAKING CHANGE:` footer, and bumps the major version.

Do not edit `CHANGELOG.md` or bump `DIGITALOCEAN_VERSION` by hand. release-please
owns both.

## Opening a pull request

1. Fork the repository.
1. Create a feature branch (`git checkout -b my-new-feature`).
1. Make your change, with tests.
1. Check it with `bundle exec rake`.
1. Push the branch and open a pull request.

Describe what changed and why. If you fixed a bug, a test that fails without your
change is the most useful thing you can include.
