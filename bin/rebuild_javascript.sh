# !/bin/sh
./node_modules/.bin/esbuild app/javascript/*.* --loader:.js=jsx --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets