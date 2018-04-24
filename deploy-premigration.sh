#!/bin/bash

ansible-playbook -i config/inventory tasks/premigration.yml -b -K

