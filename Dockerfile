#docker pull pivotalgreenhouse/ci
FROM ruby:2.1

RUN gem install bosh_cli
RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq && chmod +x /usr/local/bin/jq
RUN apt-get update && apt-get install -y python-pip zip
RUN pip install awscli

# required for https://github.com/cloudfoundry-incubator/greenhouse-ci/tree/master/scripts/ami_status.rb
RUN gem install aws-sdk

RUN echo $(jq --version && bosh --version && aws --version)


