#!/bin/sh
# compile_javascript.sh

cwd=`pwd`
folder=$1
shift;

if [ -z "${folder}" ]; then folder="." ; fi

cd ${folder}

node_modules="./node_modules"

echo "Compiling TypeScript in ${folder} ..."
${node_modules}/.bin/tsc
result=$?

if [ $result -eq 0 ]; then
    echo "TypeScript compiled successfully."
else
    echo "TypeScript compilation failed."
    exit $result
fi

echo "Compiling JavaScript in ${folder}..."
${node_modules}/esbuild/bin/esbuild --loader:.js=jsx app/javascript/application.js --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets
result=$?

if [ $result -eq 0 ]; then
    echo "JavaScript compiled successfully."
else
    echo "JavaScript compilation failed."
    exit $result
fi

cd ${cwd}
exit 0
