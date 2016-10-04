#!/bin/bash

mkdir .chef
ssh-keygen -t rsa -N "" -f .chef/delivery-validator.pem
openssl rsa -in .chef/delivery-validator.pem -pubout -out .chef/delivery-validator.pub
