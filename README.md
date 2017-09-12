# Docker/Sinatra Template

Starting template for a containerized microservice with application of the following tools:

- Docker & Docker Compose
- Sinatra, a lightweight ruby web framework
- Postgres (including a PG image for development work)
- ActiveRecord
- RABL, a templating system for generating JSON
- RSpec for model and web API testing
- Phusion Passenger & NGINX for production use
- Shotgun, an autoreloading server, for development user
- Customizations such as a JSON logging system, embedable API resources, strong parameters, and a wrapper to generate 404 errors from ActiveRecord Errors
- Convenience scripts for starting the app, view logs, pushing to Docker hub, and other tasks

## A default resource: Foo

The templates comes with a REST resource, Foo, which should probably be edited or removed when copying this template. The template includes:

- A model in `app/lib/models/foo.rb`
- A migration at `app/db/migrate/TIMESTAMP_create_foos.rb`
- REST routes in `app/app.rb`: index, show, create, update, destroy
- A convenience route in `app/app.rb`, `api/v1/new_foo` to easily make new Foo for testing purposes
- Strong parameters for Foo, also in `app/app.rb`
- RABL view for individul Foos (`app/views/api.foo.rabl`) or collections of Foos (`app/views/api.foos.rabl`)
- Unit spec for Foo at `app/spec/models/foo_spec.rb`
- API spec for all REST Routes at `app/spec/web/api_v1/foo_api_spec.rb`
- FactoryGirl factor for Foo in `app/spec/factories.rb`
- A sample rake task in `lib/tasks/count_foo.rake`

## Other things to customize

- `get "/info"` in `app/app.rb` should return text indentifying the app
- `app/views/home.erb` should be customized 
- The `title` tag should be customized in `app/views/layout.erb` (potentially the favicon as well)
- References to `username/appname` or `appname` in `script/*`
- Names of environment variables in docker-compose-production.yml
- Port mapping in both docker-compose files

## Commands

To make a new migration
```
(cd app; bundle exec rake db:create_migration NAME=create_comments)
```

To run a migration (and update test db)
```
docker-compose run app bundle exec rake db:migrate db:test:prepare
```

To create the database (first time only)
```
docker-compose run app bundle exec rake db:migrate
```

To run rspec tests
```
docker-compose run app bundle exec rspec spec
```
