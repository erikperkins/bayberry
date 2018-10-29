# Phoenix
This is the Elixir component of Data Punnet. It implements live streaming from
Twitter.

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
$ mix test --only phantomjs:true
```
To run all tests, do
```
$ mix test --include phantomjs:true
```

### Container
Docker builds the application in production mode. Migrations and
asset compilation are performed when the container starts. The container can
conveniently be run with `docker-compose`
```
$ docker-compose up phoenix
```

### Production
The build process for production follows the same sequence as for development,
with the addition of some production flags to `mix deps.get` and `brunch build`
```
$ mix deps.get --only prod
$ node node_modules/brunch/bin/brunch build --production
```
