#!/bin/bash
if [ -d ~/.hadoop.bak.d ];then
    rm -rf ~/.hadoop.bak.d
    echo "[clean]: remove .hadoop.bak.d successfully."
else
    echo "[clean]: remove .hadoop.bak.d failed, dir do not exist."
fi

if [ -f .tmp.ipcfg ];then
    rm -f .tmp.ipcfg
    echo "[clean]: remove .tmp.ipcfg successfully."
else
    echo "[clean]: remove .tmp.ipcfg failed, file do not exist."
fi

if [ -f .tmp.srccfg ];then
    rm -f .tmp.srccfg
    echo "[clean]: remove .tmp.srccfg successfully."
else
    echo "[clean]: remove .tmp.srccfg failed, file do not exist."
fi

if [ -f .tmp.slaves ];then
    rm -f .tmp.slaves
    echo "[clean]: remove .tmp.slaves successfully."
else
    echo "[clean]: remove .tmp.slaves failed, file do not exist."
fi