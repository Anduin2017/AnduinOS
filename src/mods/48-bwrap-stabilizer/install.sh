#!/bin/bash
set -e

# Stabilize bwrap by redirecting stderr to avoid deadlocks in libglycin
# This wrapper ensures that file descriptors are preserved via 'exec'.
if [ -f /usr/bin/bwrap ] && [ ! -f /usr/bin/bwrap.real ]; then
    mv /usr/bin/bwrap /usr/bin/bwrap.real
    cat << 'INNER_EOF' > /usr/bin/bwrap
#!/bin/bash
exec /usr/bin/bwrap.real "$@" 2> /dev/null
INNER_EOF
    chmod +x /usr/bin/bwrap
fi
