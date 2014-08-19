# Specify Ubuntu Saucy as base image
FROM phusion/passenger-full

# Download package lists from repositories
RUN apt-get update

# Install htop 
RUN apt-get install -y -q htop 

# Clone tmux code repository
RUN git clone git://git.code.sf.net/p/tmux/tmux-code /opt/src/tmux-code

# Install packages needed to compile binaries
RUN apt-get install -y -q build-essential autotools-dev automake pkg-config

# Make directory where repositories are cloned
RUN mkdir /opt/src || echo 'Sources directory exists already'

# Make directory where our command-line tools will installed
RUN mkdir /opt/local || echo 'Local directory exists already'

# Fetch latest modifications in case the script should be re-run
RUN cd /opt/src/tmux-code && git fetch --all

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
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh

# Create a new zsh configuration from the provided template
RUN cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc

# Set zsh as default shell
RUN chsh -s /bin/zsh root

# Install mosh server
RUN apt-get install -y -q mosh

# Generate UTF-8 locale
RUN locale-gen en_US.UTF-8

RUN /usr/bin/ssh-keygen -A

#install dotfiles
RUN curl https://raw.githubusercontent.com/gduquesnay/dotfiles/master/personal_installer.sh | sh
RUN vim +BundleInstall +qall

#install wemux
RUN git clone git://github.com/zolrath/wemux.git /usr/local/share/wemux
RUN ln -s /usr/local/share/wemux/wemux /usr/local/bin/wemux

#dependencies for pg gem
RUN apt-get install -y -q libpq-dev

#for searching code
RUN apt-get install -y -q silversearcher-ag

ADD config/wemux.conf /usr/local/etc/wemux.conf

# Copy ssh keys 
ADD ssh /root/.ssh
