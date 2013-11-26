# CustomReport

Create and view custom reports

## Installation

Add this line to your application's Gemfile:

    gem 'custom_report'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install custom_report

## Database migration

    $ rails generate custom_report
    $ rake db:migrate

## Usage

In config/initializers/custom_report.rb

    CustomReport.layout = "admin_bootstrap"
    CustomReport.includes = AuthenticatedAdminSystem
    CustomReport.admin_class = "Administrator"
    CustomReport.before_filters = [:authenticate_or_request_admin]

In your routes

    mount CustomReport::Engine => "/custom_report"

This creates the path

    /custom_report/reports



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
