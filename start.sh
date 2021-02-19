#!/bin/bash
export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi
export MIX_ENV=prod
export PORT=4780

echo "Stopping old copy..."

/home/trevor/www/hw05.downwind.xyz/bulls-and-cows/_build/prod/rel/bulls/bin/bulls stop || true

echo "Starting app..."


/home/trevor/www/hw05.downwind.xyz/bulls-and-cows/_build/prod/rel/bulls/bin/bulls start