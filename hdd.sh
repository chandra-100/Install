#!/bin/bash

#disk partition test script
fdisk /dev/vda <<EOF
n
p
1

+1000M
n
p
2

+8G
n
p
3


w
EOF



