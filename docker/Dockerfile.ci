#docker pull pivotalgreenhouse/ci
FROM ruby:2.5.1

ENV PACKER_URL "https://releases.hashicorp.com/packer/1.3.5/packer_1.3.5_linux_amd64.zip"

RUN apt-get update -qq && \
  apt-get install -qqy --no-install-recommends apt-transport-https && rm -rf /var/lib/apt/lists/*
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-jessie main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update -qq && \
  apt-get install -qqy --no-install-recommends \
    apt-utils \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    freerdp-x11 \
    g++ \
    gcc \
    git \
    google-cloud-sdk \
    libc6-dev \
    libpopt-dev \
    lsb-release \
    make \
    mingw-w64 \
    nano \
    netcat-openbsd \
    pkg-config \
    python-all \
    python-dev \
    python-pip \
    python-setuptools \
    rlwrap \
    rsync \
    unzip \
    vim \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN wget ${PACKER_URL} -O packer.zip
RUN unzip packer.zip && mv packer /usr/local/bin/packer && rm packer.zip

RUN gem install bundler

# bosh Golang CLI
RUN version_number=$(curl 'https://github.com/cloudfoundry/bosh-cli/releases/latest' 2>&1 | egrep -o '([0-9]+\.[0-9]+\.[0-9]+)') && \
  curl "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${version_number}-linux-amd64" -o /usr/local/bin/bosh && \
  chmod 755 /usr/local/bin/bosh

RUN AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get install apt-transport-https && \
    apt-get update && apt-get install azure-cli

RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq && chmod +x /usr/local/bin/jq
RUN wget -q https://github.com/mikefarah/yq/releases/download/2.3.0/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq

RUN pip install wheel --upgrade --user
RUN pip install awscli
RUN gem install aws-sdk
RUN gem install azure_mgmt_resources

ENV GOLANG_VERSION 1.12.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 2a3fdabf665496a0db5f41ec6af7a9b15a49fbe71a85a50ca38b1f13a103aeec

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH/bin"

#install CF CLI
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
RUN echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN apt-get update
RUN apt-get install cf-cli

RUN git clone https://github.com/portcullislabs/rdp-sec-check && mv rdp-sec-check/rdp-sec-check.pl /usr/local/bin && rm -rf rdp-sec-check
RUN export PERL_MM_USE_DEFAULT=1 && cpan Encoding::BER
