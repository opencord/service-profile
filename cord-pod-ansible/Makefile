CONFIG_DIR=$(shell pwd)

everything: /usr/bin/ansible
	ansible-playbook -i inventory/local --connection=local -e "config_dir=$(CONFIG_DIR)" cord-pod-playbook.yaml

/usr/bin/ansible: 
	sudo apt-get update
	sudo apt-get -y install software-properties-common curl git mosh tmux dnsutils python-netaddr
	sudo add-apt-repository -y ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get install -y ansible

stop:
	ansible-playbook -i inventory/local --connection=local -e "config_dir=$(CONFIG_DIR)" cord-pod-stop-playbook.yaml

rm: stop
	ansible-playbook -i inventory/local --connection=local -e "config_dir=$(CONFIG_DIR)" cord-pod-rm-playbook.yaml

local_containers:
	ansible-playbook -i inventory/local --connection=local -e "config_dir=$(CONFIG_DIR)" local-containers-playbook.yaml
