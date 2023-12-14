# ssh-script-function

## Introduction
I often need to perform easy tasks on a virtual machines. I don't want to install ansible and write a playbook for that, for me it's much easier to just add some commands I need to execute to my bash script.
Also, I don't want to copy ssh keys on those machines. This script allows me to ssh to a remote machines with password and performs any tasks automatically.

## Quick start
### Add ip address of your remote/virtual machines to remote_machines_ips.txt. Leave last line empty:
```
192.168.10.1
192.168.10.2
192.168.10.3
192.168.10.4
192.168.10.5

```

### Edit function.sh script. 
1) Put user of your remote machines in login value:
```
#Put your login to ssh to a remote machines in here 
login=user
```

2) Put commands you want to execute on a remote machines:
```
expect_password 'ssh $login@$ip "
sudo apt update ;\
sudo apt upgrade -y ;\
"
'
```

In this example we execute 2 commands: 
```
sudo apt update
sudo apt upgrade -y
```

You can replace those two commands with anything you need or just add a few more, also don't forget to add ";/\" at the end, e.g.:
```
expect_password 'ssh $login@$ip "
sudo apt install resolvconf -y ;\
echo nameserver $dns_ip | sudo tee /etc/resolvconf/resolv.conf.d/base ;\
echo \"options timeout: 5\" | sudo tee -a /etc/resolvconf/resolv.conf.d/base ;\
sudo rm /etc/resolv.conf ;\
sudo dpkg-reconfigure resolvconf ;\
"
'
```

Note that I added a new variable "dns_ip". You can add as many variables as you want but for that to work, you have to set the variable in function first:
```
function expect_password {
        expect -c "\
        set timeout -1
        set env(TERM)
	set ip \"$ip\"
	set login \"$login\"
	set dns_ip \"$dns_ip\"
	set your_variable \"$your_variable\"
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
```

3) Define a set of words you want to expect. In this example we expect "*password:" (feel free to use wildcards if you need it) and send value of user input from read command ($password variable). We also expect "WINS из DHCP?" and send "y". You can add phrase to expect even if it's not guaranteed for it to appear. Lets add some more phrases to expect:
```
function expect_password {
        expect -c "\
        set timeout -1
        set env(TERM)
	set ip \"$ip\"
	set login \"$login\"
	set dns_ip \"$dns_ip\"
	set your_variable \"$your_variable\"
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
        \"*default?\" {
        send \"yes\r\"
        exp_continue
        }
        \"*keep the changes?\" {
        send \"NO\r\"
        exp_continue
        }
        eof
        }
        "
}
```

4) Save the changes and start the script:
```
./function.sh
```
