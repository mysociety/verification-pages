# verification-pages

Generates position held verification and reconciliation pages for Wikidata

## Install

To run this application you will need:

- Ruby 2.3.0 or greater
- MySQL server
- Yarn

Follow these steps to clone and install the application:

    git clone https://github.com/mysociety/verification-pages.git
    cd verification-pages
    bin/setup

## Configuration

The following environment variables will need to set and configured:

    WIKIDATA_SITE=test.wikidata.org OR www.wikidata.org
    WIKIDATA_USERNAME=...
    WIKIDATA_PASSWORD=...
    SUGGESTIONS_STORE_URL=https://suggestions-store.mysociety.org/
    ID_MAPPING_STORE_BASE_URL=https://id-mapping-store.mysociety.org/
    ID_MAPPING_STORE_API_KEY=...
    HOST_NAME=verification-pages.herokuapp.com
    FORCE_SSL=1

In development this can be achieved by adding these to a `.env` file in the
project root.

## Running

To run this application follow the steps to install above, then you can start
the application server:

    foreman start

This should start the Rails server, then you can view the application by
visiting http://localhost:3000/pages. This gives you the ability to add/edit
& remove Wikidata pages which will be updated with verification page source.

To load statements from `suggestion-store` into the database by running either:

    rails verification_page:load:all

... or for a single page:

    rails verification_page:load['User:Graemebp/verification/example']

To generate a new verification page and output to stdout run:

    rails verification_page:generate['User:Graemebp/verification/example']

To generate and upload a verification page to Wikidata run:

    rails verification_page:update['User:Graemebp/verification/example']

There are also some helper tasks to update templates and JavaScript located on
Wikidata. __Warning: Running these will destroy any modifications that have been
made directly on Wikidata__

    rails verification_page:update:templates
    rails verification_page:update:javascript

## Testing

The test suite can run by:

    rspec

## Console

The Rails console allows you to play with the application's objects from the
command line. Run the following to start a console:

    rails console

## Debugging

If you need to debug part of the application drop a `binding.pry` call into the
code, when the code is executed, e.g. by visiting a URL that uses the code in
a browser, it will pause at the `binding.pry` call and drop you into a console
where you can inspect the current execution environment. See the [pry
docs](https://github.com/pry/pry) for more information.

## Troubleshooting

If `foreman start` just exits with:

    18:16:08 web.1       | exited with code 1
    18:16:08 system      | sending SIGTERM to all processes
    18:16:08 webpacker.1 | terminated by SIGTERM

... try running `rails server` to see the error message.
