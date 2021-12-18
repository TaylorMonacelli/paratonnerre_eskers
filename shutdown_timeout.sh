#!/bin/bash

start_timer() {
    i=0
    while sleep 36; do
        echo $((i++))
        date +%s >>/var/log/paratonnerre_eskers/lastrun_timestamp.log
    done | zenity --progress \
        --text="To conserve resources we will auto-shutdown this host in an hour. To extend your time for another hour, cancel this popup." \
        --title="Autoshutdown in 1h" \
        --width=300 --height=200 \
        --auto-close
    retVal=$?

    if [ $retVal -ne 0 ]; then
        echo "I'm still here!"
        date +%s >>/var/log/paratonnerre_eskers/signal_im_still_here.log
    else
        echo "I've moved on"
        date +%s >>/var/log/paratonnerre_eskers/signal_shutdown.log
        sudo shutdown now
    fi
}

while true; do
    start_timer
    sleep 1m
done
