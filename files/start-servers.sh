#!/usr/bin/env bash
# Поднимает 3 simple python сервера на портах 8081/8082/8083.

set -e

for i in 1 2 3; do
    port=$((8080 + i))
    dir="/srv/web${i}"
    mkdir -p "$dir"
    echo "SERVER ${i} netol hw" > "${dir}/index.html"
    (cd "$dir" && setsid python3 -m http.server "$port" >/dev/null 2>&1 &)
    echo "SERVER ${i} -> http://127.0.0.1:${port}"
done

sleep 1
ss -tlnp | grep -E '8081|8082|8083'
