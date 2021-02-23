#!/bin/bash
export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi
export MIX_ENV=prod
export PORT=4792

echo "Stopping old copy..."

/home/hw06/hw06/bulls-and-cows/_build/prod/rel/bulls/bin/bulls stop || true

echo "Starting app..."


/home/hw06/hw06/bulls-and-cows/_build/prod/rel/bulls/bin/bulls start
