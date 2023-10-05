#!/bin/bash
set  history-limit 16000
eval $(ssh-agent)
ssh-add key.pem
