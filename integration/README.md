# Integration suites

The unit suite stubs HTTP at the wire, so it can prove the driver *sends* the
right request but never that DigitalOcean accepts it. These suites close that
gap: each one creates a real Droplet and asserts, on the Droplet, that the
driver configured it the way the suite asked for.

They are not part of `rake default`. They create real Droplets and cost real
money.

## What each suite covers

| Suite | What it proves |
| --- | --- |
| `default` | Create, converge over SSH and destroy, and that `ubuntu-24` resolves to an image DigitalOcean still offers. |
| `image-slug` | A platform name that is *not* in `PLATFORM_SLUG_MAP` reaches the API as a slug untouched. |
| `server-name` | An explicit `server_name` survives to the Droplet unchanged. |
| `tags` | `tags` written as a YAML list reach the Droplet. |
| `tags-string` | `tags` written as a delimited string are split into separate tags, not sent as one tag with a comma in it. |
| `user-data` | `user_data` reaches cloud-init verbatim and runs. |
| `ipv6` | `ipv6: true` gets the Droplet a routable v6 address. |
| `monitoring` | `monitoring: true` installs and starts the DigitalOcean metrics agent. |
| `size-region` | A non-default `size` and `region` are accepted together and are the pair that was asked for. |
| `firewalls` | `attach_firewalls` places the Droplet behind a cloud firewall without locking the transport out. |

The assertions read the [DigitalOcean metadata
service](https://docs.digitalocean.com/reference/api/metadata-api/) from the
Droplet. That is the closest thing to reading back the request the driver sent,
and it needs no credentials on the Droplet.

## Running them

You need an account, a personal access token with write scope, and an SSH key
uploaded to DigitalOcean.

```bash
bundle install
export DIGITALOCEAN_ACCESS_TOKEN=dop_v1_...
export DIGITALOCEAN_SSH_KEY_IDS=12345678
export KITCHEN_SSH_KEY=~/.ssh/id_kitchen_digitalocean   # the matching private key

cd integration
bundle exec kitchen list
bundle exec kitchen test default-ubuntu-24
```

Or from the repository root:

```bash
bundle exec rake integration:test      # everything
bundle exec rake integration:destroy   # clean up after a failed run
```

`kitchen test` destroys on success. It leaves the Droplet up on failure so you
can log in and look, so **run `kitchen destroy` when you are done** — or
`rake integration:destroy`, which does it for every suite.

### Settings

| Variable | Default | Purpose |
| --- | --- | --- |
| `DIGITALOCEAN_ACCESS_TOKEN` | *none* | Required. Token with write scope. |
| `DIGITALOCEAN_SSH_KEY_IDS` | *none* | Required. ID or fingerprint of an uploaded key. |
| `KITCHEN_SSH_KEY` | `~/.ssh/id_kitchen_digitalocean` | Private key the transport logs in with. |
| `KITCHEN_DO_REGION` | `nyc3` | Region most suites deploy into. |
| `KITCHEN_DO_ALT_REGION` | `sfo3` | Second region, used by `size-region`. |
| `KITCHEN_DO_SIZE` | `s-1vcpu-1gb` | Droplet size. |
| `KITCHEN_DO_FIREWALL_ID` | *none* | Cloud firewall for the `firewalls` suite. Without it that suite reports itself skipped. |
| `KITCHEN_RUN_ID` | `local` | Tagged onto every Droplet as `run-<id>`, so a leaked one can be traced back. |

## Cost and cleanup

Ten Droplets, all `s-1vcpu-1gb` bar one, alive for a few minutes each. A full
run is cents rather than dollars — but a Droplet that outlives the run is not,
so every Droplet is tagged `kitchen-digitalocean-integration` and
`run-<KITCHEN_RUN_ID>`. If a run is interrupted:

```bash
doctl compute droplet list --tag-name kitchen-digitalocean-integration
doctl compute droplet delete --tag-name kitchen-digitalocean-integration
```

## In CI

`.github/workflows/integration.yml` runs these weekly against `main`, and on
demand through **Actions → Integration Tests → Run workflow**. It is never
triggered by a pull request: secrets are not available to forks, and every run
costs money.

It needs one repository secret, `DIGITALOCEAN_ACCESS_TOKEN`. Everything else is
created for the run and deleted afterwards — an ed25519 key pair uploaded to the
account, and a cloud firewall for the `firewalls` suite — so no long-lived SSH
key is stored anywhere.

Three details matter more than they look:

* **`Destroy everything` runs with `if: always()`.** A suite that leaks Droplets
  on failure turns a red build into a recurring bill.
* **A tag sweep runs after it, also with `if: always()`.** If `kitchen destroy`
  could not run at all — a cancelled job, a crashed runner — the tag is the way
  back to the Droplets.
* **`concurrency: digitalocean-integration` with `cancel-in-progress: false`.**
  Droplet limits are per account; two overlapping runs exhaust them and both
  fail.

## Adding a suite

Add it to `kitchen.yml` with a script in `scripts/`. Assertions live in the
**provisioner**, not a verifier: the script is transferred over the driver's own
transport and executed on the Droplet, so reaching the machine at all is part of
every assertion, and a non-zero exit fails the suite.

The shell provisioner uploads only the one file it is pointed at, so each script
repeats the same short preamble rather than sourcing a helper. Values that vary
per run arrive as `arguments:`, since the provisioner has no way to pass
environment variables.

Keep each suite pointed at one behaviour — when it fails, its name should say
what broke.
