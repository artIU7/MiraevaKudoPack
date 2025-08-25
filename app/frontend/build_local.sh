#!/bin/bash
echo "open chrome without croc ..."
open -n -a "Google Chrome" --args --disable-web-security --user-data-dir=/tmp/chrome-dev
npm start
echo "finish ..."
