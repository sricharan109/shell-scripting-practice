#!/bin/bash
time = $(date)
echo "$time at this we played"
time1= $(date +%s)
sleep 10
time2= $(date +%s)
total= $(($time2-$time1))
echo "the diff is $total"