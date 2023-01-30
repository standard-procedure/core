# Standard Procedure
This is the core library for the Standard Procedure app, implemented as a Rails Engine.
Currently, I'm very early in the development of this, so it's probably a bit ropey and you might want to ignore it for a while.

Eventually I want this to be a full Rails Engine that allows you to install the full Standard Procedure system, with API, into your Rails app - so you just need to configure it for your clients and add on your own UI.

## Usage
Include the gem in your Rails application.

Then create the migrations ...
and update your ApplicationRecord to load the various modules:

```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include StandardProcedure::HasName
  include StandardProcedure::HasDescription
  include StandardProcedure::HasLogo
  include StandardProcedure::HasReference
  include StandardProcedure::HasFields
  include StandardProcedure::HasLinkedItems
  include StandardProcedure::HasAncestors
  include StandardProcedure::HasCommands
  include StandardProcedure::HasFieldDefinitions
  include StandardProcedure::HasFieldValues
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "standard-procedure", github: "standard-procedure/core"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install standard_procedure
```

## Contributing
Please fork and raise pull requests.  Tests are written using RSpec.

To test, use the dummy app:
```bash
cd spec/dummy
bin/rails db:setup
bin/rails db:test:prepare
bin/rails spec
```
The dummy app contains models that are used to test the various modules defined in the actual library.  Migrations for these models are in spec/dummy/db/migrate - as opposed to migrations for the library itself, which are in db/migrate.
## License
The gem is available as open source under the terms of the [LGPL License](https://www.gnu.org/licenses/lgpl-3.0.en.html).
This means that you can use this code in your proprietary app, but you must make the Standard Procedure Core library available, under the terms of the LGPL.  Plus, if you make any amendments to the library, you must also publish those changes under the same licence.
Commercial licensing is available - contact rahoulb@standardprocedure.app for details.
