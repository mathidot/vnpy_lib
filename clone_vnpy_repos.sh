#!/bin/bash

repos=(
vnpy_rest
vnpy_websocket
vnpy_ctp
vnpy_ctptest
vnpy_xtp
vnpy_tts
vnpy_rohon
vnpy_mini
vnpy_sopt
vnpy_uft
vnpy_esunny
vnpy_comstar
vnpy_ib
vnpy_tap
vnpy_da
vnpy_femas
vnpy_ost
vnpy_tora
vnpy_hft
vnpy_sec
vnpy_hts
vnpy_ctastrategy
vnpy_ctabacktester
vnpy_riskmanager
vnpy_datamanager
vnpy_webtrader
vnpy_spreadtrading
vnpy_datarecorder
vnpy_chartwizard
vnpy_optionmaster
vnpy_algotrading
vnpy_scripttrader
vnpy_portfoliomanager
vnpy_portfoliostrategy
vnpy_paperaccount
vnpy_excelrtd
vnpy_rpcservice
vnpy_sqlite
vnpy_mysql
vnpy_postgresql
vnpy_mongodb
vnpy_influxdb
vnpy_dolphindb
vnpy_leveldb
vnpy_rqdata
vnpy_tushare
vnpy_tqsdk
vnpy_udata
vnpy_tinysoft
vnpy_ifind
vnpy_wind
)

for repo in "${repos[@]}"; do
    echo "Cloning $repo..."
    git clone "https://github.com/vnpy/$repo.git"
    if [ $? -eq 0 ]; then
        echo "$repo cloned successfully."
    else
        echo "Error cloning $repo."
    fi
    echo "--------------------"
done

echo "All cloning attempts finished."
