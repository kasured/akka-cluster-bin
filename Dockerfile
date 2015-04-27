FROM kasured/centos-oraclejdk-sbt
MAINTAINER Evgeny Rusak "kasured@gmail.com"

## [start block] Concerns
# Okay, so here comes the biggest concern as of the time of commit
# ssh-keygen -q -t rsa -N '' -f akka-cluster-ro -C 'akka-cluster-ro'

# So the question is to how get the git public/private repo checked out/cloned etc
# 1) Add keys and then delete them from container. Nope, build will have layered history
# 2) have the volume outside of the container. Nope, cause the context of the Dockerfile 
# 3) "Deployment key" for ro access to the repo 
#     Both bitbucket/github provide this conception, but be sure to use them specifiacally for that repo

# Please see more details here https://github.com/docker/docker/issues/6396
RUN mkdir /root/.ssh
ADD ssh/keys /root/.ssh
ADD ssh/config /root/.ssh/
RUN chmod -vR 600 /root/.ssh/*
RUN ssh-keyscan -T 60 bitbucket.org > /root/.ssh/known_hosts
## [end block] Concerns

RUN git clone git@bitbucket.org:kasur/akka-cluster.git /opt/akka-cluster

WORKDIR /opt/akka-cluster

RUN sbt stage

CMD ["/bin/bash"]
