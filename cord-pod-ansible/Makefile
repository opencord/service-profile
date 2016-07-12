CONFIG_DIR=$(shell pwd)

everything: /usr/bin/ansible
	ansible-playbook -i inventory/local --connection=local -e "config_dir=$(CONFIG_DIR)" cord-pod.yaml

/usr/bin/ansible: 
	sudo apt-get -y install ansible
