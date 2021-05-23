#!/usr/bin/env bash

# Installs the Ruby client for tunnel-vision

INSTALL_PATH=/usr/local/bin/tunnel-vision

curl 'https://raw.githubusercontent.com/abhchand/tunnel-vision/master/lib/client/ruby/tunnel-vision.rb' > $INSTALL_PATH
chmod +x $INSTALL_PATH

echo "Done - installed to $INSTALL_PATH"
echo "Run \`tunnel-vision --help\` to get started"
