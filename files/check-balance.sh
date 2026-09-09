#!/usr/bin/env bash
#---------------------------------------------------------------------
# Сбор статистики балансировки.
#
#   ./check-balance.sh 90 example.local   # задание 2 (веса 2:3:4)
#   ./check-balance.sh 20                 # задание 1 (round-robin 1:1)
#
# 90 запросов при весах 2/3/4 (сумма 9) должны дать ровно 20/30/40.
#---------------------------------------------------------------------

COUNT=${1:-90}
HOST=${2:-}
URL="http://localhost/"

echo "Отправляю ${COUNT} запросов на ${URL} ${HOST:+(Host: $HOST)}"
echo

for _ in $(seq 1 "$COUNT"); do
    if [ -n "$HOST" ]; then
        curl -s -H "Host: ${HOST}" "$URL"
    else
        curl -s "$URL"
    fi
done | sort | uniq -c | sort -rn | awk -v total="$COUNT" \
    '{printf "%-25s %4d ответов  (%5.1f%%)\n", $2" "$3" "$4, $1, $1*100/total}'

echo
echo "Всего: ${COUNT}"
