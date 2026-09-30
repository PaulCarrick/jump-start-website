# Ruby and Rails upgrade

The application now targets Ruby **4.0.7**, Rails **8.1.4**, and Bundler **4.0.20**. The Ruby version is pinned in `.ruby-version` and `Gemfile`; resolved gem versions are recorded in `Gemfile.lock`. Rails 8.1 framework defaults are enabled.

## Local development

Ruby 4.0.7 is installed at `/Users/paul/.rbenv/versions/4.0.7` on the development Mac, alongside the existing Ruby. Activate it in a terminal before running Rails or Bundler:

```sh
export PATH="$HOME/.rbenv/versions/4.0.7/bin:$PATH"
cd /Users/paul/src/jump-start-website
ruby --version
bundle --version
bundle check
```

Restart the development server with the new Ruby after stopping the existing server. A running process continues using its original Ruby and loaded gems. With another version manager, install the version in `.ruby-version` and select it for this project.

`bin/start_server.sh` reads `.ruby-version` and selects an installed rbenv or ruby-install runtime. `bin/admin-ui-e2e` selects the pinned runtime before building assets or creating its disposable database, and puts that Ruby's executables on PATH for its child processes.

## Compatibility and refactoring

- Updated Rails dependencies needed for Ruby 4 and Rails 8.1, including native extensions, Rack, Devise, Ransack, RSpec Rails, React/Rails integration, and serializers. Added the separately distributed `benchmark` gem for image-processing dependencies. Kept Pagy's existing compatible API.
- Matched Action Text's JavaScript package to Rails 8.1.4 (published on npm as `8.1.400`).
- Consolidated admin pagination and sorting, applied configured page limits consistently, and corrected clearing persisted sorting for the current resource.
- Removed redundant exception blocks and replaced `throw` with exceptions handled by the controller's existing error path.
- Consolidated checksum verification, removed duplicate save callbacks, and preserved the existing four-round SHA-512 format. Invalid records now carry Active Record errors rather than passing a message as a record.
- Updated RSpec fixture configuration and corrected old page/section specs to use the current `page_id` association.
- Updated Docker and the Linux installer to the pinned Ruby and current Bundler. The installer reads `.ruby-version` and includes the YAML build dependency.

## Validation

Focused backend checks: 29 passing examples across `spec/upgrades`, `spec/models/concerns`, and `spec/models/page_spec.rb`. These cover checksums, tampered content, sorting, pagination, page associations, authenticated rendering, and admin page CRUD. Validation used a fresh disposable test database, which was dropped afterward.

Also passed: Rails boot/version verification, Zeitwerk eager-loading check, Ruby lint for the refactored files, 27 mocked Python installer tests, shell syntax, JavaScript/CSS builds, TypeScript checking, and Git whitespace checks.

The full Selenium suite remains the next verification step. Run it in your terminal with your usual database connection environment:

```sh
cd /Users/paul/src/jump-start-website
bin/admin-ui-e2e
```

The Docker image and a real Linux installation have not been built or exercised by these local checks. The focused specs are not a complete run of every legacy RSpec file.
