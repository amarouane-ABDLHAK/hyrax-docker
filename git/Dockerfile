###############################################################################################
# 
# Dockerfile for single container Hyrax
#
#
# Some shell state reference:
# set -f # "set -o noglob"  Disable file name generation using metacharacters (globbing).
# set -v # "set -o verbose" Prints shell input lines as they are read.
# set -x # "set -o xtrace"  Print command traces before executing command.
# set -e #  Exit on error.
#
# In general use "set -e" when running commands that matter and don't use
# it for debugging stuff.
#
# Set one or more individual labels
FROM centos:7

LABEL vendor="OPeNDAP Incorporated"
LABEL org.opendap.hyrax.version="1.13.4"
LABEL org.opendap.hyrax.version.is-production="false"

MAINTAINER support@opendap.org

USER root

ARG DEVELOPER_MODE
ENV DEVELOPER_MODE ${DEVELOPER_MODE:-"false"}
RUN set -e && \
    if [ $DEVELOPER_MODE = "true" ];then echo "DEVELOPER_MODE: ENABLED"; else echo "DEVELOPER_MODE: DISABLED"; fi

ARG BRANCH
ENV BRANCH ${BRANCH:-"master"}
RUN set -e && \
    echo "BRANCH: ${BRANCH}"


# Update and install the needful.
RUN set -e \
    && yum -y install \
       ant \
       autoconf \
       automake \
       bison \
       bzip2-devel \
       curl-devel \
       flex \
       gcc-c++ \
       git \
       java-1.7.0-openjdk \
       java-1.7.0-openjdk-devel \
       junit \
       libicu-devel \
       libjpeg-devel \
       libtool \
       libuuid-devel \
       libxml2-devel \
       make \
       openssl-devel \
       readline-devel \
       tomcat \
       unzip  \
       wc \
       which \
       zlib-devel \
    && yum -y update \
    && yum clean all 

# Tomcat environment (Tomcat installed above by via yum)
ENV CATALINA_HOME /usr/share/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN echo "CATALINA_HOME: $CATALINA_HOME"

###############################################################
# Get the source code from github
RUN echo "Cloning hyrax"
RUN set -e \
    && git clone https://github.com/opendap/hyrax \
    && cd hyrax \
    && . ./spath.sh \
    && ./hyrax_clone.sh 

###############################################################
# Build Hyrax dependencies 
RUN echo "Building Hyrax dependencies"
RUN set -e \
    && cd hyrax \
    && . ./spath.sh \
    && cd hyrax-dependencies \
    && make -j9


###############################################################
# Build libdap
RUN echo "Building libdap"
RUN set -e \
    && cd hyrax \
    && . ./spath.sh \
    && cd libdap4 \
    && git checkout ${BRANCH} \
    && autoreconf -vif \
    && ./configure --prefix=$prefix \
    && make -j9 \
    && make check \
    && make install
    
    
###############################################################
# Build BES 
RUN echo "Building bes"
RUN set -e \
    && cd hyrax \
    && . ./spath.sh \
    && cd bes \
    && git checkout ${BRANCH} \
    && git submodule foreach git checkout ${BRANCH} \
    && autoreconf -vif \
    && ./configure --prefix=$prefix --with-dependencies=$prefix/deps \
    && make -j9 \
    && make install
     
###############################################################
# Build OLFS 
RUN echo "Building olfs"
RUN set -e \
    && cd hyrax \
    && . ./spath.sh \
    && cd olfs \
    && git checkout ${BRANCH} \
    && ant server \
    && cp ./build/dist/opendap.war /usr/share/tomcat/webapps
     
    
    
    
#RUN echo "Building hyrax"
#RUN set -e \
#    && cd hyrax \
#    && . ./spath.sh \
#    && ./hyrax_build.sh


# HYRAX VERSION INFO
#ENV HYRAX_VERSION=1.13.4 
#ENV LIBDAP_VERSION=3.19.0-1
#ENV BES_VERSION=3.18.0-1
#ENV OLFS_VERSION=1.16.3


    
    
###############################################################


COPY entrypoint.sh /
RUN  set -e && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
EXPOSE 8443
EXPOSE 10022
EXPOSE 11002

# can't use USER with entrypoint that needs root
# use gosu or, as done, enable bes user write so the entrypoint does not need root
#RUN  set -e && chown -R bes /etc/bes
USER root

CMD ["-"]

