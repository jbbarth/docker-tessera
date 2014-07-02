FROM debian:wheezy

MAINTAINER Jean-Baptiste BARTH <jeanbaptiste.barth@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

#backports for nodejs
RUN echo deb http://http.debian.net/debian wheezy-backports main > /etc/apt/sources.list.d/wheezy-backports.list && apt-get update
RUN apt-get upgrade -y

#tessera prerequisites
RUN apt-get install -y nodejs python python-virtualenv gcc git curl
RUN update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100
RUN curl https://www.npmjs.org/install.sh | clean=no sh

#(following https://github.com/urbanairship/tessera/blob/master/docs/Build.md from now on)

#setting up the python environment
RUN git clone https://github.com/urbanairship/tessera.git /opt/tessera
WORKDIR /opt/tessera
RUN virtualenv .
#replaces ". bin/activate" after inspection...
ENV VIRTUAL_ENV /opt/tessera
ENV PATH /opt/tessera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pip install -r requirements.txt; pip install -r dev-requirements.txt

#setting up the javascript environment
RUN npm install -g grunt-cli; npm install; grunt

#create the database
RUN inv initdb
RUN inv json.import 'demo/*'

#configure
#TODO...

#run
EXPOSE 5000
CMD ["inv", "run"]
