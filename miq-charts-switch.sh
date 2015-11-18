#!/bin/bash

base=$(pwd)

if [ $1 == "on" ]; then
  if [ -d vmdb ]; then
    cd vmdb/config
  else
    cd config
  fi

  ln -s ~/Projects/cfme_productization/manageiq/config/ziya_charting.yml

  cd $base

  if [ -d vmdb ]; then
    cd vmdb/public
  else
    cd public
  fi

  ln -s ~/Projects/cfme_productization/manageiq/public/charts

  echo "Config --> Configuration --> Server --> Advanced"
  echo "product: report_sync: true"

else
  if [ -d vmdb ]; then
    cd vmdb
  fi
  rm config/ziya_charting.yml public/charts
fi

