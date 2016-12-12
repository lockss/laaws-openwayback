FROM centos:latest

MAINTAINER "Daniel Vargas" <dlvargas@stanford.edu>

RUN yum -y install java tar lsof vim openssh-clients
RUN yum -y update && yum clean all

RUN curl -SL http://mirror.cc.columbia.edu/pub/software/apache/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz \ 
  | tar xzC /opt && \
    ln -s /opt/apache-tomcat-8.5.9 /opt/tomcat

WORKDIR /opt/tomcat/webapps
RUN rm -rf {ROOT,docs,examples}
RUN curl -SL http://search.maven.org/remotecontent?filepath=org/netpreserve/openwayback/openwayback-dist/2.3.0/openwayback-dist-2.3.0.tar.gz \
  | tar xz openwayback/openwayback-2.3.0.war && \
    mv openwayback/openwayback-2.3.0.war ROOT.war && \
    rmdir openwayback

# Workaround to preparing an OpenWayback WAR overlay
RUN /opt/tomcat/bin/catalina.sh start && \
    sleep 30 && \
    /opt/tomcat/bin/catalina.sh stop

ADD wayback.xml /opt/tomcat/webapps/ROOT/WEB-INF/
RUN mkdir -p /srv/openwayback
  
ADD tomcat.sh /etc/profile.d/
ADD motd /etc/motd
ADD entry /usr/local/bin/
RUN chmod +x /usr/local/bin/entry

WORKDIR /opt/tomcat

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
