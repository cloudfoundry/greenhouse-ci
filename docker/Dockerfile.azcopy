#docker pull pivotalgreenhouse/ci
FROM ubuntu:16.04

RUN apt update
RUN apt install curl wget -y

RUN apt-get update -qq && \
  apt-get install -qqy --no-install-recommends apt-transport-https && rm -rf /var/lib/apt/lists/*

# install ruby
#
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.3
RUN bash -l -c "ruby -v"
RUN bash -l -c "gem install bundler --no-ri --no-rdoc"

#Install Python
RUN apt-get update -qq && \
  apt-get install -qqy --no-install-recommends \
    lsb-release \
    python-all \
    python-dev \
    python-pip \
    python-setuptools \
    && rm -rf /var/lib/apt/lists/*

#install powershell :trollface:
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list
RUN apt-get update
RUN apt-get install -y powershell

# install azcopy
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod/ xenial main" > azure.list && \
    cp ./azure.list /etc/apt/sources.list.d/ && \
    apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF && \
    apt-get update && \
    apt install -y azcopy
# bosh Golang CLI
RUN version_number=$(curl 'https://github.com/cloudfoundry/bosh-cli/releases/latest' 2>&1 | egrep -o '([0-9]+\.[0-9]+\.[0-9]+)') && \
  curl "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${version_number}-linux-amd64" -o /usr/local/bin/bosh && \
  chmod 755 /usr/local/bin/bosh

# Install Python -- required for Azure CLI 2.0
# from https://github.com/dockerfile/python/blob/master/Dockerfile
# RUN \
#   apt-get update && \
#   apt-get install -y python python-dev python-pip python-virtualenv && \
#   rm -rf /var/lib/apt/lists/*

# azure CLI
# from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest#install-on-debianubuntu-with-apt-get

RUN AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && apt-get install azure-cli


RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq && chmod +x /usr/local/bin/jq

RUN bash -l -c "gem install azure_mgmt_resources"

ENV GOLANG_VERSION 1.9
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH/bin"

RUN echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc

#install azstemcell
RUN apt install git -y
RUN git clone https://github.com/pivotal-cf-experimental/azstemcell
RUN cd azstemcell && go build && mv azstemcell /usr/bin

#install pigz
RUN apt install pigz -y
