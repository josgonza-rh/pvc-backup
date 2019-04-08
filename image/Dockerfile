FROM centos:7
MAINTAINER josgonza@redhat.com

ENV IMAGE_SCRIPTS_HOME /opt/pvc-backup
ENV USER_PASS='Backup123'

RUN \
  mkdir $IMAGE_SCRIPTS_HOME && \
  groupadd -g 65534 nfsnobody && \
  groupadd -g 10001 backup && \
  useradd -r -u 10001 -g backup --home-dir $IMAGE_SCRIPTS_HOME backup && \
  groupadd -g 10002 rsyncuser && \
  useradd -r -u 10002 -g rsyncuser -G nfsnobody --home-dir $IMAGE_SCRIPTS_HOME rsyncuser && \
  echo "${USER_PASS}" | passwd rsyncuser --stdin

RUN \
  yum rsync -y install \
  yum clean all

COPY backup.sh $IMAGE_SCRIPTS_HOME/

RUN \  
  chmod u+s /usr/bin/sed && \
  chmod +x $IMAGE_SCRIPTS_HOME/backup.sh 

USER 10001
WORKDIR $IMAGE_SCRIPTS_HOME

ENTRYPOINT ["/bin/bash", "backup.sh"]
