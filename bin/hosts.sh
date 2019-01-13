#!/bin/bash

# OpenShift cluster nodes
[[ $(grep '172.99.36.254 control.lab.example.com control' /etc/hosts) ]] || echo '172.99.36.254 control.lab.example.com control' >> /etc/hosts

[[ $(grep '172.99.36.5 master.lab.example.com master' /etc/hosts) ]] || echo '172.99.36.5 master.lab.example.com master' >> /etc/hosts

[[ $(grep '172.99.36.6 infra-node1.lab.example.com infra-node1' /etc/hosts) ]] || echo '172.99.36.6 infra-node1.lab.example.com infra-node1' >> /etc/hosts

[[ $( grep '172.99.36.7 node1.lab.example.com node1' /etc/hosts) ]] || echo '172.99.36.7 node1.lab.example.com node1' >> /etc/hosts

[[ $( grep '172.99.36.8 node2.lab.example.com node1' /etc/hosts) ]] || echo '172.99.36.8 node2.lab.example.com node2' >> /etc/hosts

