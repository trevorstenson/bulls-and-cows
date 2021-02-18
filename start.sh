#!/bin/bash
export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi
export MIX_ENV=prod
export PORT=4780

echo "Stopping old copy of app, if any..."

/home/trevor/www/hw05.downwind.xyz/cs4550-hw04/_build/prod/rel/practice/bin/practice stop || true

echo "Starting app..."

/home/trevor/www/hw04.downwind.xyz/cs4550-hw04/_build/prod/rel/practice/bin/practice start

# TODO: Add a systemd service file
#       to start your app on system boot.

