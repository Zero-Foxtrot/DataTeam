FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu60 \
    libunwind8 \
    netcat \
    libssl1.0 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

# Add our build agent requirements
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=ibm-semeru-runtimes:open-8-jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN mkdir /java
ENV JAVA_HOME11=/opt/java/openjdk11
COPY --from=ibm-semeru-runtimes:open-11-jdk $JAVA_HOME $JAVA_HOME11
#ENV PATH="${JAVA_HOME}/bin:${PATH}"
# End of BT environment set up

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

COPY ./test.sh .
RUN chmod +x test.sh

ENTRYPOINT ["./start.sh"]
