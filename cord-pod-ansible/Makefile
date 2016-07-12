CONFIG_DIR=$(shell pwd)

everything: /usr/bin/ansible
	ANSIBLE_LIBRARY=CONFIG_DIR/../modules ansible-playbook -i inventory/local --connection=local -e "config_dir=$(CONFIG_DIR)" cord-pod.yaml

/usr/bin/ansible: 
	sudo apt-get update
	sudo apt-get -y install software-properties-common curl git mosh tmux dnsutils python-netaddr
	sudo add-apt-repository -y ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get install -y ansible
