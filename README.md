# verification-pages

Generates position held verification and reconciliation pages for Wikidata

## Install

To run this application you will need:

- Ruby 2.3.0 or greater
- PostgreSQL server
- Yarn

Follow these steps to clone and install the application:

    git clone https://github.com/mysociety/verification-pages.git
    cd verification-pages
    bundle install
    rails db:setup
    yarn install

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

To load statements from `suggestion-store` into the database call:

    `rails verification_page:load['User:Graemebp/verification/example']`

To generate a new verification page and output to stdout call:

    `rails verification_page:generate['User:Graemebp/verification/example']`

To generate and upload a verification page to Wikidata call:

    `rails verification_page:update['User:Graemebp/verification/example']`

There are also some helper tasks to managed templates and JavaScript located on
Wikidata. These have to be used with care as they will destroy an modifications
made directly on Wikidata. These can be called by:

    `rails verification_page:update:templates`
    `rails verification_page:update:javascript`

## Testing

The test suite can be run by runing:

    rspec
