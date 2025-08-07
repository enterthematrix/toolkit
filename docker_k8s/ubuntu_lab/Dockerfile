FROM debian:bullseye

# Install core packages + zsh + fonts + sudo
RUN apt update && apt install -y \
    vim curl wget net-tools iputils-ping htop psmisc tree man less git \
    zsh fonts-powerline fonts-firacode unzip locales sudo procps lsof \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Set up default locale (helps avoid zsh prompt errors)
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Set root password
RUN echo 'root:root' | chpasswd

# Create non-root user 'sanju' with zsh and add to sudo group
RUN useradd -m -s /bin/zsh sanju && \
    usermod -aG sudo sanju && \
    echo 'sanju ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/sanju && \
    chmod 0440 /etc/sudoers.d/sanju

USER sanju
WORKDIR /home/sanju

# Install Oh My Zsh and Powerlevel10k theme
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Update .zshrc with theme and alias
RUN echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc && \
    echo 'alias ll="ls -lah"' >> ~/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc

# Set zsh as default shell
CMD ["zsh"]

# Instructions to build and run the Docker image

# docker build -t linux-lab .
# docker run -it linux-lab bash