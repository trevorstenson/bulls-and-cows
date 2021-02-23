#!/bin/bash

# export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi
# export MIX_ENV=prod
# export PORT=4780
# export NODEBIN=`pwd`/assets/node_modules/.bin
# export PATH="$PATH:$NODEBIN"

# echo "Building..."

# mix deps.get
# mix compile
# (cd assets && npm install)
# (cd assets && webpack --mode production)
# mix phx.digest

# echo "Generating release..."
# mix release

# #echo "Stopping old copy of app, if any..."
# #_build/prod/rel/practice/bin/practice stop || true

# echo "Starting app..."

export MIX_ENV=prod
export PORT=4780
export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi

mix local.hex --force
mix deps.get --only prod
mix compile

npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest

mix release
