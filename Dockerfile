FROM centos:latest

MAINTAINER "Daniel Vargas" <dlvargas@stanford.edu>

EXPOSE 8080

RUN yum -y install java tar lsof vim openssh-clients
RUN yum -y update && yum clean all

RUN curl -SL https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.tar.gz \
  | tar xzC /opt && \
    ln -s /opt/apache-tomcat-8.5.11 /opt/tomcat

WORKDIR /opt/tomcat/webapps
RUN rm -rf {ROOT,docs,examples}

RUN curl -SL http://search.maven.org/remotecontent?filepath=org/netpreserve/openwayback/openwayback-dist/2.3.1/openwayback-dist-2.3.1.tar.gz \
  | tar xz openwayback/openwayback-2.3.1.war && \
    mv openwayback/openwayback-2.3.1.war ROOT.war && \
    rmdir openwayback

# XXX Only necessary for debugging
ADD tomcat/tomcat.sh /etc/profile.d/
ADD tomcat/setenv.sh /opt/tomcat/conf/
ADD tomcat/server.xml /opt/tomcat/conf/

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
