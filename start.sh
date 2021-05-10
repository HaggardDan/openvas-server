#! /bin/bash

envsubst << EOF > /usr/local/etc/openvas/openvas.conf
db_address = $REDIS_URL
EOF

