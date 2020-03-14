#!/usr/bin/env bash

set -e

# ------ settings -----

AMAZON_NEPTUNE_CLUSTER_ENDPOINT=____PUT_YOUR_AMAZON_NEPTUNE_CLUSTER_ADDRESS_HERE____ <----

TINKERPOP_GREMLIN_VERSION=3.4.6
AMAZON_CERT=https://www.amazontrust.com/repository/SFSRootCAG2.pem
# ---------------------

TINKERPOP_GREMLIN_DOWNLOAD=https://archive.apache.org/dist/tinkerpop/$TINKERPOP_GREMLIN_VERSION/apache-tinkerpop-gremlin-console-$TINKERPOP_GREMLIN_VERSION-bin.zip

echo Downloading latest tinkerpop gremlin
wget -O gremlin.zip $TINKERPOP_GREMLIN_DOWNLOAD

echo unzipping tickerpop gremlin
unzip -qq gremlin.zip
rm gremlin.zip

echo creating symbolic link
ln -s ./apache-tinkerpop-gremlin-console-$TINKERPOP_GREMLIN_VERSION ./tinkerpop-gremlin

mkdir neptune

echo Downloading amazon ca certificate
wget -O neptune/SFSRootCAG2.pem $AMAZON_CERT

echo Generating neptune remote yaml
cat > neptune/neptune-remote.yaml << EOF
hosts: [$AMAZON_NEPTUNE_CLUSTER_ENDPOINT]
port: 8182
connectionPool: { enableSsl: true, trustCertChainFile: "../neptune/SFSRootCAG2.pem"}
serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { serializeResultToString: true }}
EOF

echo Generating neptune startup script
cat > neptune/neptune-startup-script << EOF
:remote connect tinkerpop.server ../neptune/neptune-remote.yaml
:remote console
EOF

echo Generating gremlin shell script
cat > gremlin.sh << EOF
#!/usr/bin/env bash

set -e

./tinkerpop-gremlin/bin/gremlin.sh -i neptune/neptune-startup-script
EOF

chmod +x gremlin.sh

echo Run 'gremlin.sh' to startup tinkerpop gremlin console
