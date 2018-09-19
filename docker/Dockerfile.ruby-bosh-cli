#docker pull pivotalgreenhouse/ci
FROM ruby:2.5.1

RUN gem install bosh_cli bundler

RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq && chmod +x /usr/local/bin/jq
RUN apt-get update && apt-get install -y python-pip zip apt-utils python-dev
RUN pip install awscli

# required for https://github.com/cloudfoundry-incubator/greenhouse-ci/tree/master/scripts/ami_status.rb
RUN gem install aws-sdk-v1 aws-sdk octokit

RUN echo $(jq --version && bosh --version && aws --version)

#install go
# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        libc6-dev \
        make \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.7.4
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 47fda42e46b4c3ec93fa5d4d4cc6a748aa3f9411a2a2b7e08e3a6d80d753ec8b

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN \
  wget -q "https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip" -P /tmp/ && \
  unzip /tmp/spiff_linux_amd64.zip -d /usr/local/bin && \
  rm /tmp/spiff_linux_amd64.zip
