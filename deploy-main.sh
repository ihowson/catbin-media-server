#!/bin/bash

ansible-playbook -i config/inventory playbook.yml -b -K

