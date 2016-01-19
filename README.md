# lamassu-admin

Lamassu admin server. First part of Lamassu stack you need to install.

## Installation

```sh
git clone git@github.com:coinme-engineering/coinme-admin.git
cd coinme-admin
npm install
```

You also need a Postgres running. Postgres is required for storing configuration
of the remote server. Install Postgres with your package manager of choice, then:

```sh
sudo su - postgres
createuser --superuser lamassu
createdb -U lamassu lamassu
```

Then you need SQL scripts to seed initial configs. They are under `/database`.
You can bootstrap your database by running:

```sh
psql lamassu lamassu < database/lamassu.sql
```

## Configuration
You'll be able to configure your stack when you start the server for the first
time.

## Running

```sh
npm start
```

Then, [open it](http://localhost:3000).

## Deployment

```sh
npm run deploy
```

Visit the deployed application to configure your Lamassu ATM. Make sure to input
all required API keys.

Next, to deploy `lamassu-server` you need to grab `DATABASE_URL` for the Postgres
database our deployment script created.

```sh
db=$(heroku config:get DATABASE_URL)
```

Then, go to `lamassu-server` and deploy it:

```sh
DATABASE_URL="$db" ./deploy.sh
```

You need to pass `DATABASE_URL` to it since both `lamassu-admin` and `lamassu-server`
use the same database.

Both applications should be deployed and running.
