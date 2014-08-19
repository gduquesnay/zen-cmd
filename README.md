zen-cmd
=======

Dockerfile used to build a zen command-line environment for remote pair-programming


Usage
=====
on the host... in my case a digital ocean droplet running ubuntu 14.04
----------------------------------------------------------------------
```
Install docker
git clone https://github.com/gduquesnay/zen-cmd
cd zen-cmd
cp ~/.ssh/* ssh
mkdir ~/code
docker run --name db -d postgres  
docker build -t dockerpairing .
docker run --rm -t -i --link db:db -v ~/code:/root/code -p 3000:3000 -p 10022:22 -p 60000:60000/udp -p 60001:60001/udp -p 60002:60002/udp dockerpairing
```

on your local
-------------
```
export LC_ALL=en_US.UTF-8
mosh --ssh="ssh -p 10022" root@<ip.of.host>
```
