#!/bin/sh

. ~/.asdf/asdf.sh

source /srv/extick/env.sh

export MIX_ENV=prod
export PHX_SERVER=true
export PHX_PORT=4000
export PHX_HOST=vps-28e1f96e.vps.ovh.net

mix deps.get --only prod
mix compile
mix assets.deploy
mix release

/srv/extick/rel/bin/extick stop

cp -r _build/prod/rel/extick/* /srv/extick/rel

/srv/extick/rel/bin/extick daemon
/srv/extick/rel/bin/extick eval Extick.Release.migrate
