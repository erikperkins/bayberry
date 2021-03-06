# Bayberry [![Build Status](https://travis-ci.com/erikperkins/bayberry.svg?branch=master)](https://travis-ci.com/erikperkins/bayberry) [![Coverage Status](https://coveralls.io/repos/github/erikperkins/bayberry/badge.svg)](https://coveralls.io/github/erikperkins/bayberry)
This is the Elixir component of Data Punnet. It is the main website, and
handles live streaming from Twitter.

## Build
### Development
Local development requires Elixir and Phoenix to be
[installed](https://hexdocs.pm/phoenix/installation.html). Live code reloading
requires [`inotify-tools`](https://github.com/rvoicilas/inotify-tools/wiki); on Debian-based distributions, this can be installed with
`apt-get install inotify-tools`. Phoenix requires
[NodeJS](https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
for JavaScript package management. A local PostgreSQL `development` user with
`createdb` permissions is needed for database access.

Once the required OS packages are installed, the project's Elixir dependencies
must be retrieved and compiled
```
$ mix deps.get
$ mix deps.compile
```
To completely clean the Elixir packages, simply delete `mix.lock` and the `deps` and `_build` directories. Next, JavaScript dependencies must be fetched in the
`assets` directory
```
$ cd assets
$ npm install
```
This will create the `assets/node_modules` directory. If a clean build is required, run `npm cache clean`, or delete the `node_modules` directory wholesale. To compile static assets, run the custom `mix` task
```
$ mix phx.assets
```
This is a wrapper for running `brunch` and `mix phx.digest`. To run these commands separately, first run `brunch` from the `assets` directory
```
$ node node_modules/brunch/bin/brunch/build
```
Switch back to the project root and run
```
$ mix phx.digest
```
to digest and compress the static assets, which places the output in `/priv`. Create, migrate, and seed the database in a single step with
```
$ mix ecto.setup
```
Finally, run the server with
```
$ mix phx.server
```

### Test
Tests are split into two groups: unit and acceptance. Acceptance tests are
tagged with `@tag phantomjs: true`, and use the PhantomJS webdriver.
To run unit tests only, do
```
$ mix test
```
To run acceptance tests only, do
```
$ mix test --only acceptance:true
```
To run all tests, do
```
$ mix test --include acceptance:true
```
To see test coverage, do
```
$ mix coveralls
```
This step is performed on the continuous integration platform, and the results
are forwarded to [coveralls.io](https://coveralls.io).

### Continuous Integration
TravisCI is used for continuous integration. Pipelines are defined in
`.travis.yml`. Sensitive environment variables included in `.travis.yml` must
be encrypted with the `travis` Ruby gem. Install the gem with
```
$ gem install travis
```
and encrypt credentials, API tokens, etc. with
```
$ travis encrypt SENSITIVE_ENVIRONMENT_VARIABLE=value --add env.global
```
which will inject the encrypted value into `.travis.yml`.

### Container
Docker builds the application in production mode
```
$ docker build -t erikperkins/bayberry .
```
Migrations and asset compilation are performed when the container starts. The container can be run with
```
$ docker-compose up
```

### Production
The build process for production follows the same sequence as for development,
with the addition of some production flags to `mix deps.get` and `brunch build`
```
$ mix deps.get --only prod
$ node node_modules/brunch/bin/brunch build --production
```
