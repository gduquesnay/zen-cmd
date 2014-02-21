# Specify Ubuntu Saucy as base image
FROM ubuntu:saucy

MAINTAINER Thierry Marianne

# Download package lists from repositories
RUN apt-get update

# Install a decent text editor
RUN apt-get install -y -q vim

# Install htop 
RUN apt-get install -y -q htop 

# Add user with name "theodoer" and password "elvish_word_for_friend"
RUN useradd -d /home/theodoer -p JXFBFm7Klstpw -m -s /bin/zsh theodoer

# Leveraging git
RUN apt-get install -y -q git

# Install packages needed to compile binaries
RUN apt-get install -y -q build-essential autotools-dev automake pkg-config

# Make directory where repositories are cloned
RUN mkdir /opt/src || echo 'Sources directory exists already'

# Make directory where our command-line tools will installed
RUN mkdir /opt/local || echo 'Local directory exists already'

## Install tmux ##

# Clone tmux code repository
RUN git clone git://git.code.sf.net/p/tmux/tmux-code /opt/src/tmux-code

# Checkout latest tmux tag
RUN cd /opt/src/tmux-code && git checkout tags/1.9

# Install tmux dependencies
RUN apt-get install -y -q libncurses5-dev libevent-dev

# Configure tmux installation
RUN cd /opt/src/tmux-code && apt-get install -y -q  && sh autogen.sh && ./configure --prefix=/opt/local/tmux

# Compile tmux and install its binaries
RUN cd /opt/src/tmux-code && make && make install && ln -s /opt/local/tmux/bin/tmux /usr/bin

## Install oh-my-zsh ##

# Install zsh
RUN apt-get install -y -q zsh

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~theodoer/.oh-my-zsh

# Create a new zsh configuration from the provided template
RUN cp ~theodoer/.oh-my-zsh/templates/zshrc.zsh-template ~theodoer/.zshrc

# Set zsh as default shell
RUN chsh -s /bin/zsh theodoer

# Install openssh server
RUN apt-get install -y -q openssh-server

# Disables password authentication
RUN sed -i -e 's/^#PasswordAuthentication\syes/PasswordAuthentication no/' /etc/ssh/sshd_config

# pam_loginuid is disabled
RUN sed -i -e 's/^\(session\s\+required\s\+pam_loginuid.so$\)/#\1/' /etc/pam.d/sshd

# Install mosh server
RUN apt-get install -y -q mosh

# Generate UTF-8 locale
RUN locale-gen en_US.UTF-8

# Create missing privilege separation directory
RUN mkdir /var/run/sshd

# Make ssh directory of theodoer user
RUN mkdir ~theodoer/.ssh

# Copy ssh keys pair to home directory of theodoer user
ADD ./ssh/zen-cmd.pub /home/theodoer/.ssh/authorized_keys

# Make ssh directory of theodoer user
CMD /usr/bin/sshd -d

# Expose ssh port and mosh port
EXPOSE 22 6000
