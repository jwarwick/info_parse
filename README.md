# InfoParse

Elixir project built with Dyanmo and Ecto. Used to display information captured with `info_gather`.

To create a backup of a heroku postgres database:
`heroku pgbackups:capture`

To download the capture:
`curl -o latest.dump \`heroku pgbackups:url\``

To import the capture into postgres:
`pg_restore --verbose --clean --no-acl --no-owner -d infogather latest.dump`

## Postgres Setup
This application assumes you have a database `infogather` created which holds the tables defined in the
`info_gather` project.

This application uses a new database called `infoparse`.

``` sql

 CREATE DATABASE infoparse;

```

There is a mix helper defined to create the required tables. Run `mix db.create`.

