#! /bin/bash

envsubst > /usr/local/etc/openvas/openvas.conf << EOF
db_address = $REDIS_URL
EOF

