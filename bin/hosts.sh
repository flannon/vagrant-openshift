#!/bin/bash

# OpenShift cluster nodes
[[ $(grep '172.99.36.254 control.lab.example.com control' /etc/hosts) ]] || echo '172.99.36.254 control.lab.example.com control' >> /etc/hosts

[[ $(grep '172.99.36.6 master.lab.example.com master' /etc/hosts) ]] || echo '172.99.36.8 master.lab.example.com master' >> /etc/hosts

[[ $( grep '172.99.36.7 appnode0.lab.example.com appnode0' /etc/hosts) ]] || echo '172.99.36.9 appnode0.lab.example.com appnode0' >> /etc/hosts

[[ $( grep '172.99.36.8 appnode1.lab.example.com appnode1' /etc/hosts) ]] || echo '172.99.36.9 appnode0.lab.example.com appnode1' >> /etc/hosts

