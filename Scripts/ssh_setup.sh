sudo chmod 700 ~/.ssh/*
ssh-add $(find ~/.ssh/* | grep ".*\.pub$" | sed 's/\.pub$//') > /dev/null 2>&1

