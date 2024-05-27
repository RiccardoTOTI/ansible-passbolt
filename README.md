# passbolt_ansible
A complete (set of) playbook(s) to selfhost passbolt.

## HOW-TO:

German: https://neuroforge.de/passbolt-ein-open-source-passwort-manager/

## Short (english) HOW-TO:

### Preparations

```
virtualenv ansible-manager 
source ansible-manager/bin/activate
pip3 install ansible
ansible-galaxy install geerlingguy.docker, geerlingguy.mysql
```

### Step by Step

1. Adapt `files/certs/passbolt_server/gen_root_cert.sh` and `files/certs/passbolt_server/gen_server_cert.sh` to generate certificates that fit your organisation. (Tip: search for `emailAddress=test@your-domain.it`)
2. run `sudo bash files/certs/passbolt_server/gen_root_cert.sh files/certs/passbolt_server/passbolt_mariadb_cert` 
3. run `sudo bash files/certs/passbolt_server/gen_server_cert.sh files/certs/passbolt_server/passbolt_mariadb_cert/ files/certs/passbolt_server/passbolt_mariadb_cert/ www.passbolt.it` put CN of your choice
4. run `sudo bash files/certs/passbolt_server/gen_root_cert.sh files/certs/passbolt_server/mariadb_server_cert`
5. run `sudo bash files/certs/passbolt_server/gen_server_cert.sh files/certs/passbolt_server/mariadb_server_cert/ files/certs/passbolt_server/mariadb_server_cert/ www.passbolt.it` put CN of your choice
6. create ssh-pub to put in the VM, run `ssh-keygen -t rsa -b 2048 -f ./ssh_keys/root_rsa`
7. put to the VM, `ssh-copy-id -i /ssh_keys/root_rsa.pub user@ip_address`

2. Adapt `files/certs/passbolt_server/recreate_server_certs.sh` and replace the placeholders accordingly
3. Adapt `inventories/passbolt/group_vars/all/all_config.yml` according to the comments in the file.
4. Adapt your Ansible inventory to point to the correct IP in `inventories/passbolt/hosts.yml`.
5. Run `ansible-playbook -i inventories/passbolt_sever/hosts.yml full_setup.yml`.
6. Connect to the passbolt shell with `bash passbolt_shell.sh <your-server-ip>`
7. Run `su -c "./bin/cake passbolt register_user -u admin@yourorg.com -f Admin -l Adminson -r admin" -s /bin/bash www-data`
8. Complete the Passbolt setup in your browser.

## (Manual backups)

1. Run `bash manual_backup.sh <your-ip>`

and/or

1. Export all passwords in the Passbolt UI
