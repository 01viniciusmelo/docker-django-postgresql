FROM ubuntu_django
MAINTAINER Rafael Belliard <rafael@codemera.com>

ENV USER    reb
ENV DB      reb

ENV LANG C.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Create the database
RUN service postgresql start && \
    # Run on boot
    update-rc.d postgresql enable && \

    # Setup the database
    sudo -H -u postgres createuser root && \
    sudo -H -u postgres createdb reb && \
    sudo -H -u postgres createdb template_postgis && \
    sudo -H -u postgres psql reb -c 'alter user root with superuser;' && \
    service postgresql stop

# Set permissions
RUN service postgresql start && \
    createuser reb && \
    psql reb -c 'alter user reb with superuser;' && \
    psql reb -c 'create extension postgis;' && \
    psql reb -c 'create extension postgis_topology;' && \
    psql reb -f /usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR/legacy_minimal.sql && \
    psql template_postgis -c 'create extension postgis;' && \
    psql template_postgis -c 'create extension postgis_topology;' && \
    psql template_postgis -c 'create extension fuzzystrmatch;' && \
    psql template_postgis -c 'create extension postgis_tiger_geocoder;' && \
    psql template_postgis -c 'create or replace procedural language plpythonu;' && \
    psql template_postgis -c 'create extension ltree;' && \
    psql template_postgis -c 'create extension intarray;' && \
    psql template_postgis -f /usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR/legacy_minimal.sql && \
    service postgresql stop

RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/$PG_MAJOR/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/$PG_MAJOR/main/postgresql.conf && \
    echo "hot_standby=off" >> /etc/postgresql/$PG_MAJOR/main/postgresql.conf

RUN pip install virtualenvwrapper

RUN mkdir -p /usr/share/virtualenvwrapper/ && \
  ln -s /usr/local/bin/virtualenvwrapper_lazy.sh /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh

RUN useradd -d /home/reb -m reb && echo "reb:reb" | chpasswd && adduser reb sudo
RUN groupadd docker && gpasswd -a reb docker && newgrp docker

# Bash setup.
RUN echo "export CLICOLOR=1" >> /home/reb/.bashrc && \
    echo "export LSCOLORS=GxFxCxDxBxegedabagaced" >> /home/reb/.bashrc && \
    echo "WORKON_HOME=/home/reb/.virtualenvs" >> /home/reb/.bashrc && \
    echo "PROJECT_HOME=/home/reb" >> /home/reb/.bashrc && \
    echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python" >> /home/reb/.bashrc && \
    echo "PS1=\"\u:\w \"" >> /home/reb/.bashrc && \
    echo "alias postgresql.start=\"sudo service postgresql start\"" >> /home/reb/.bashrc && \
    echo "alias postgresql.stop=\"sudo service postgresql stop\"" >> /home/reb/.bashrc && \
    echo "alias postgresql.restart=\"sudo service postgresql restart\"" >> /home/reb/.bashrc && \
    echo "alias run=\"workon django && cd /home/reb/django && ./manage.py runserver 0:8000\"" >> /home/reb/.bashrc && \
    echo "alias start=\"postgresql.restart && run\"" >> /home/reb/.bashrc && \
    echo "hardstatus alwayslastline" >> /home/reb/.screenrc && \
    echo "hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{=kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B}%Y-%m-%d %{W}%c %{g}]'" >> /home/reb/.screenrc && \
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/reb/.bashrc && \
    service postgresql stop

ADD ./requirements /home/reb/setup/requirements

# Log-in with user "reb".
USER      reb
WORKDIR   /home/reb
ENV HOME  /home/reb

RUN /bin/bash -c \
     "source /usr/local/bin/virtualenvwrapper.sh && \
      mkvirtualenv --no-site-packages django && \
      workon django && \
      pip install -r setup/requirements/base.txt --no-cache-dir && \
      pip install ipdb ipython --no-cache-dir"

RUN eval "$(ssh-agent)"

CMD /bin/bash

EXPOSE 5432
EXPOSE 8000
