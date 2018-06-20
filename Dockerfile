# Copyright (c) 2000-2018, Board of Trustees of Leland Stanford Jr. University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM centos:latest

MAINTAINER "Daniel Vargas" <dlvargas@stanford.edu>

# Set container entrypoint
ENTRYPOINT ["/init.sh"]

RUN rpm --import https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/RPM-GPG-KEY-cloudera
# RUN curl -o /etc/yum.repos.d/cloudera-cdh5.repo https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/cloudera-cdh5.repo
ADD cloudera/cloudera-cdh5.repo /etc/yum.repos.d/cloudera-cdh5.repo

# Install and update packages
RUN yum -y install java tar lsof vim openssh-clients hadoop-hdfs-fuse
RUN yum -y update && yum clean all && rm -rf /var/cache/yum

# Install Apache Tomcat
RUN curl -SL https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.tar.gz \
  | tar xzC /opt && \
    ln -s /opt/apache-tomcat-8.5.11 /opt/tomcat

# Cleanup webapps directory
RUN rm -rf /opt/tomcat/webapps/{ROOT,docs,examples}

# Install the OpenWayback webapp
RUN curl -SL http://search.maven.org/remotecontent?filepath=org/netpreserve/openwayback/openwayback-dist/2.3.1/openwayback-dist-2.3.1.tar.gz \
  | tar xz openwayback/openwayback-2.3.1.war && \
    mv openwayback/openwayback-2.3.1.war /opt/tomcat/webapps/ROOT.war && \
    rmdir openwayback

# Add scripts and configuration files
ADD tomcat/tomcat-env.sh /etc/profile.d/
ADD tomcat/bin/setenv.sh /opt/tomcat/bin/
ADD tomcat/conf/server.xml /opt/tomcat/conf/

ADD scripts/init.sh /init.sh