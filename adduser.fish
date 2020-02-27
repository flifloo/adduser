#!/usr/bin/fish
set PORT 44322

if [ "$argv[1]" = "-h" ] || [ "$argv[1]" = "--help" ] || [ -z "$argv" ]
	echo "adduser <host> <user> <key path> [port]"
	exit 0
else if [ -z "$argv[3]" ]
	echo "Not enouth arguments !"
	exit 1
else if [ -n "$argv[5]" ]
	echo "Too many arguments !"
	exit 1
else if [ ! -f "$argv[3]" ]
	echo "Invalid key file !"
	exit 1
end

set host $argv[1]
set user $argv[2]
set key (cat $argv[3])

set debug "> /dev/null"

if [ -n "$argv[4]" ]
	set port $argv[4]
else
	set port $PORT
end

set pass (date +%s | sha256sum | base64 | head -c 32 ; echo)
echo "$user passwd: $pass"

set adduser "echo -e '$pass\n$pass\n' | adduser $user --shell /usr/bin/fish --gecos ',,,' $debug && adduser $user sudo $debug"
set setup_ssh "mkdir /home/$user/.ssh $debug && chown $user:$user /home/$user/.ssh $debug && chmod 700 /home/$user/.ssh $debug"
set add_key "echo '$key' > /home/$user/.ssh/authorized_keys && chown $user:$user /home/$user/.ssh/authorized_keys $debug && chmod 600 /home/$user/.ssh/authorized_keys $debug"

set cmd ""

for i in $adduser $setup_ssh $add_key
	if [ -n "$cmd" ]
		set cmd "$cmd && $i"
	else
		set cmd "$i"
	end
end

ssh -t $host -p $port sudo bash -c \"$cmd\"
