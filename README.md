[![Docker](http://i.imgur.com/ZMHZYDx.png)](https://www.docker.com)

# Example setup for a Django + PostgreSQL Docker container.

## Run the server

```
docker start django
docker attach django
start
```

* Navigate to [http://localhost:8000](http://localhost:8000).

## Container setup

### Create the container

* Install [Docker for Mac](https://docs.docker.com/docker-for-mac/).
* Run the `Docker.app`.

```
docker build -t ubuntu_django -f 01_ubuntu.dockerfile .
docker build -t django -f 02_django.dockerfile .
```

* (Optional) Install [Kitematic](https://kitematic.com/).

### Start your container

When starting your first container, you want to use a [mounted volume](https://docs.docker.com/engine/tutorials/dockervolumes/) which allows you
to share the code base between your host operating system and the docker container.

Modify your workspace path appropiatedly:

1. `/home/reb/django`: The main Django repository.
2. `/home/reb/postgresql-dumps`: A folder containing PostgreSQL `.sql` dump files.
3. `/home/reb/.virtualenvs/django/src`: The virtual environment's repository source files.
4. `/home/reb/.ssh`: The SSH configuration to use.

Finally:

```
docker run -it -d \
    -p 127.0.0.1:5432:5432 \
    -p 127.0.0.1:8000:8000 \
    --publish-all=true \
    -m 4Gb \
    -v ~/workspace/django:/home/reb/django \
    -v ~/workspace/postgresql-dumps:/home/reb/dumps \
    -v ~/.virtualenvs/django/src/:/home/reb/.virtualenvs/django/src \
    -v ~/.ssh:/home/reb/.ssh \
    --name django django
```

### Run the container

```
docker attach django
```

* The user is `reb` and its password is also `reb`.

### Install the database

```
postgresql.start
psql -d reb -f $(ls dumps/*.sql|tail -n -1)
```

### Install missing requirements

```
eval "$(ssh-agent)"
ssh-add
workon django
cd ~/django
pip install -r requirements/base.txt
```

### Setup the dabatabase

```
./manage.py syncdb
./manage.py migrate
./manage.py migrate sessions zero --fake
./manage.py migrate sessions
```

### Run the server

```
run
```

* Navigate to [http://localhost:8000](http://localhost:8000).

### Commit the container

Commit your container to avoid re-doing all of these steps.

* Before committing it, ensure the PostgreSQL database is stopped to avoid issues restarting it.

```
docker commit django
```

* Note: It will take a few minutes.


### Troubleshooting

If you want to remove Docker data:

```
docker rm $(docker ps -a -q)
docker ps -a | sed '1 d' | awk '{print $1}' | xargs -L1 docker rm
docker images -a | sed '1 d' | awk '{print $3}' | xargs -L1 docker rmi -f
```
