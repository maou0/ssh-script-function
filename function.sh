#!/bin/bash

# A script to ssh to every remote machine from remote_machines_ips.txt file 
# and execute a set of commands of your choice.
# For this script to work:
# 1) Put your value in login variable.
# 2) Replace/add block in expect function with word/set of words you want to expect and desired reply (read comments bellow)
# 3) Fill remote_machines_ips.txt with ip adresses of your remote machines, every ip on a new line, also leave last string empty.
# 4) Execute bash script and input your password when asked.
start=$SECONDS

#Put your login to ssh to a remote machines in here 
login=user

# Script will ask to input your password (for account in login variable above, e.g. user) to access remote machines after you start this script
read -sp "Enter password: " password

# Colors to make output interminal more readable.
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# A function to ssh on a remote machine.
# Expect block contains key words we want to expect and send a reply.
# E.g. we are expecting:
# 1) word "password" to send a value of variable $password (we got it from user input in read command)
# 2) a set of words "WINS из DHCP?" to send a "y".
# You can replace 2nd set of words to anything you need OR 
# you can just add a new block in expect, as many time as you want. E.g. :
# \"*any sets of words to expect here*\" {
#        send \"any reply we want to send here\r\"
#        exp_continue
#        }
# Note that we can use wildcard (* symbol) as we did above.
function expect_password {
        expect -c "\
        set timeout -1
        set env(TERM)
	set ip \"$ip\"
	set login \"$login\"
        spawn $1
	expect {
        \"*password:\" {
        send \"$password\r\"
        exp_continue
        }
        \"WINS из DHCP?\" {
        send \"y\r\"
        exp_continue
        }
        eof
        }
        "
}

mkdir -p ~/.ssh

# While loop to process every ip from remote_machines_ips.txt
while read ip; do

echo -e "\n\n${GREEN}--- MACHINE ${ip} ---${NC}\n"

echo -e "\n${YELLOW}Adding to known_hosts ${CYAN}${ip}${NC}\n"
ssh-keyscan -H -T 30 $ip >> ~/.ssh/known_hosts

echo -e "\n${YELLOW}Executing task on ${CYAN}${ip}${NC}\n"

# Put your commands here instead of those two. Don't forget to ecape special characters and quotes, e.g.
# echo \"$ipa\" ;\
# Always put ";\" (without quotes) after every command like in example below.
expect_password 'ssh $login@$ip "
sudo apt update ;\
sudo apt upgrade -y ;\
"
'

done < ./remote_machines_ips.txt

# Output how much time has passed to execute script (in minutes).
end=$SECONDS
runtime=$((end-start))
echo -e "\n${YELLOW}It took ${CYAN}$((runtime / 60))${YELLOW} min to execute ${CYAN}${0}${YELLOW} script.${NC}\n"
