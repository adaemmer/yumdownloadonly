FROM centos:7
RUN yum install -y yum-plugin-downloadonly yum-utils createrepo

COPY ./offlinecopy.sh /
ENTRYPOINT ["/offlinecopy.sh"]


