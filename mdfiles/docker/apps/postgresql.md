[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建镜像

```shell
#!/bin/bash
set -e
# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
EOF

# 【构建镜像】

IMAGE_NAME="hrs-postgresql"
IMAGE_TAG="11.7"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
SOURCES_LIST=$(cat /data1/docker/apps/apt-sources.list)
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM postgres:11.7

ARG  PG_CNF_FILE=/etc/postgresql/postgresql.conf
ENV  TZ=Asia/Shanghai \\
     POSTGRES_PASSWORD=HRS123321

RUN  set -x && \\
     cp /usr/share/postgresql/postgresql.conf.sample \$PG_CNF_FILE && \\
# 修改监听IP
     sed -i "s/^[[:space:]]*#[[:space:]]*listen_addresses.*/listen_addresses='*'/" \$PG_CNF_FILE ; \\
     sed -i "s/^[[:space:]]*listen_addresses.*/listen_addresses='*'/" \$PG_CNF_FILE ; \\
# 修改最大连接数 原则：max_connections > ( max_wal_senders + superuser_reserved_connections )
     sed -i "s/^[[:space:]]*#[[:space:]]*max_connections.*/max_connections=20/" \$PG_CNF_FILE ; \\
     sed -i "s/^[[:space:]]*max_connections.*/max_connections=20/" \$PG_CNF_FILE ; \\
# 修改共享内存
     sed -i "s/^[[:space:]]*#[[:space:]]*shared_buffers.*/shared_buffers=32MB/" \$PG_CNF_FILE ; \\
     sed -i "s/^[[:space:]]*shared_buffers.*/shared_buffers=32MB/" \$PG_CNF_FILE

EOF
# ----------------- Dockerfile End  -----------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo "================================================================"
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo "================================================================"
```
几点说明：
- "echo debconf ..." ： 这句是为了解决构建过程中提示系统服务要重启的(yes/no)选择问题
- "locales 和 localedef" ： 这是为了安装en_US.utf8，否则在initdb的时候，会报错：invalid locale settings; check LANG and LC_* environment variables
- "TZ=Asia/Shanghai" ： 为了让容器中的时间是东八区


# 启动容器
```shell
CAR_NAME="hrs-pgsql"
DATA_DIR="/data2/DockerUserWorkEnv/UserWorkfolder/hrs-pssql/PGDATA" && mkdir -p $DATA_DIR
sudo docker container run -d -p 35432:5432 --name $CAR_NAME \
     -v $DATA_DIR:/var/lib/postgresql/data \
     -e POSTGRES_PASSWORD=123456 \
     hrs-postgresql:11.7 -c 'config_file=/etc/postgresql/postgresql.conf'
# 或者，启动时直接设置配置参数
     hrs-postgresql:11.7 -c 'shared_buffers=256MB' -c 'max_connections=200'
```

# 用容器执行psql执行
```shell
sudo docker container run --rm -it hrs-postgresql:11.7 psql -U postgres -h 容器的IP  # docker inspect hrs-pgsql|grep IPAddress
# 执行以上命令进入psql交互环境，看看配置是否生效了
show max_connections;
show shared_buffers;

# 修改 pg_hba.conf ，可以避免每次连接都输入密码
echo "host all all 192.168.8.169/32  trust" >> pg_hba.conf
```

# 常用命令
[常用命令](../../db/pgsql)

# 官方Dockerfile
```dockerfile
# vim:set ft=dockerfile:
FROM debian:stretch-slim

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# explicitly set user/group IDs
RUN set -eux; \
	groupadd -r postgres --gid=999; \
# https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
# also create the postgres user's home directory with appropriate permissions
# see https://github.com/docker-library/postgres/issues/274
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates wget

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN set -eux; \
	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# install "nss_wrapper" in case we need to fake "/etc/passwd" and "/etc/group" (especially for OpenShift)
# https://github.com/docker-library/postgres/issues/359
# https://cwrap.org/nss_wrapper.html
		libnss-wrapper \
# install "xz-utils" for .sql.xz docker-entrypoint-initdb.d files
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint-initdb.d

RUN set -ex; \
# pub   4096R/ACCC4CF8 2011-10-13 [expires: 2019-07-02]
#       Key fingerprint = B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
# uid                  PostgreSQL Debian Repository
	key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
	command -v gpgconf > /dev/null && gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	apt-key list

ENV PG_MAJOR 11
ENV PG_VERSION 11.7-2.pgdg90+1

RUN set -ex; \
	\
# see note below about "*.pyc" files
	export PYTHONDONTWRITEBYTECODE=1; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
		amd64 | i386 | ppc64el) \
# arches officialy built by upstream
			echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
			apt-get update; \
			;; \
		*) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from their published source packages
			echo "deb-src http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
			\
			case "$PG_MAJOR" in \
				9.* | 10 ) ;; \
				*) \
# https://github.com/docker-library/postgres/issues/484 (clang-6.0 required, only available in stretch-backports)
# TODO remove this once we hit buster+
					echo 'deb http://deb.debian.org/debian stretch-backports main' >> /etc/apt/sources.list.d/pgdg.list; \
					;; \
			esac; \
			\
			tempDir="$(mktemp -d)"; \
			cd "$tempDir"; \
			\
			savedAptMark="$(apt-mark showmanual)"; \
			\
# build .deb files from upstream's source packages (which are verified by apt-get)
			apt-get update; \
			apt-get build-dep -y \
				postgresql-common pgdg-keyring \
				"postgresql-$PG_MAJOR=$PG_VERSION" \
			; \
			DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" \
				apt-get source --compile \
					postgresql-common pgdg-keyring \
					"postgresql-$PG_MAJOR=$PG_VERSION" \
			; \
# we don't remove APT lists here because they get re-downloaded and removed later
			\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
# (which is done after we install the built packages so we don't have to redownload any overlapping dependencies)
			apt-mark showmanual | xargs apt-mark auto > /dev/null; \
			apt-mark manual $savedAptMark; \
			\
# create a temporary local APT repo to install from (so that dependency resolution can be handled by APT, as it should be)
			ls -lAFh; \
			dpkg-scanpackages . > Packages; \
			grep '^Package: ' Packages; \
			echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list; \
# work around the following APT issue by using "Acquire::GzipIndexes=false" (overriding "/etc/apt/apt.conf.d/docker-gzip-indexes")
#   Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
#   ...
#   E: Failed to fetch store:/var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages  Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
			apt-get -o Acquire::GzipIndexes=false update; \
			;; \
	esac; \
	\
	apt-get install -y --no-install-recommends postgresql-common; \
	sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf; \
	apt-get install -y --no-install-recommends \
		"postgresql-$PG_MAJOR=$PG_VERSION" \
	; \
	\
	rm -rf /var/lib/apt/lists/*; \
	\
	if [ -n "$tempDir" ]; then \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
		apt-get purge -y --auto-remove; \
		rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list; \
	fi; \
	\
# some of the steps above generate a lot of "*.pyc" files (and setting "PYTHONDONTWRITEBYTECODE" beforehand doesn't propagate properly for some reason), so we clean them up manually (as long as they aren't owned by a package)
	find /usr -name '*.pyc' -type f -exec bash -c 'for pyc; do dpkg -S "$pyc" &> /dev/null || rm -vf "$pyc"; done' -- '{}' +

# make the sample config easier to munge (and "correct by default")
RUN set -eux; \
	dpkg-divert --add --rename --divert "/usr/share/postgresql/postgresql.conf.sample.dpkg" "/usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample"; \
	cp -v /usr/share/postgresql/postgresql.conf.sample.dpkg /usr/share/postgresql/postgresql.conf.sample; \
	ln -sv ../postgresql.conf.sample "/usr/share/postgresql/$PG_MAJOR/"; \
	sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH $PATH:/usr/lib/postgresql/$PG_MAJOR/bin
ENV PGDATA /var/lib/postgresql/data
# this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
```

#### docker-enrypoint.sh

```shell
#!/usr/bin/env bash
set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
        local var="$1"
        local fileVar="${var}_FILE"
        local def="${2:-}"
        if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
                echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
                exit 1
        fi
        local val="$def"
        if [ "${!var:-}" ]; then
                val="${!var}"
        elif [ "${!fileVar:-}" ]; then
                val="$(< "${!fileVar}")"
        fi
        export "$var"="$val"
        unset "$fileVar"
}

# check to see if this file is being run or sourced from another script
_is_sourced() {
        # https://unix.stackexchange.com/a/215279
        [ "${#FUNCNAME[@]}" -ge 2 ] \
                && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
                && [ "${FUNCNAME[1]}" = 'source' ]
}

# used to create initial postgres directories and if run as root, ensure ownership to the "postgres" user
docker_create_db_directories() {
        local user; user="$(id -u)"

        mkdir -p "$PGDATA"
        chmod 700 "$PGDATA"

        # ignore failure since it will be fine when using the image provided directory; see also https://github.com/docker-library/postgres/pull/289
        mkdir -p /var/run/postgresql || :
        chmod 775 /var/run/postgresql || :

        # Create the transaction log directory before initdb is run so the directory is owned by the correct user
        if [ -n "$POSTGRES_INITDB_WALDIR" ]; then
                mkdir -p "$POSTGRES_INITDB_WALDIR"
                if [ "$user" = '0' ]; then
                        find "$POSTGRES_INITDB_WALDIR" \! -user postgres -exec chown postgres '{}' +
                fi
                chmod 700 "$POSTGRES_INITDB_WALDIR"
        fi

        # allow the container to be started with `--user`
        if [ "$user" = '0' ]; then
                find "$PGDATA" \! -user postgres -exec chown postgres '{}' +
                find /var/run/postgresql \! -user postgres -exec chown postgres '{}' +
        fi
}

# initialize empty PGDATA directory with new database via 'initdb'
# arguments to `initdb` can be passed via POSTGRES_INITDB_ARGS or as arguments to this function
# `initdb` automatically creates the "postgres", "template0", and "template1" dbnames
# this is also where the database user is created, specified by `POSTGRES_USER` env
docker_init_database_dir() {
        # "initdb" is particular about the current user existing in "/etc/passwd", so we use "nss_wrapper" to fake that if necessary
        # see https://github.com/docker-library/postgres/pull/253, https://github.com/docker-library/postgres/issues/359, https://cwrap.org/nss_wrapper.html
        if ! getent passwd "$(id -u)" &> /dev/null && [ -e /usr/lib/libnss_wrapper.so ]; then
                export LD_PRELOAD='/usr/lib/libnss_wrapper.so'
                export NSS_WRAPPER_PASSWD="$(mktemp)"
                export NSS_WRAPPER_GROUP="$(mktemp)"
                echo "postgres:x:$(id -u):$(id -g):PostgreSQL:$PGDATA:/bin/false" > "$NSS_WRAPPER_PASSWD"
                echo "postgres:x:$(id -g):" > "$NSS_WRAPPER_GROUP"
        fi

        if [ -n "$POSTGRES_INITDB_WALDIR" ]; then
                set -- --waldir "$POSTGRES_INITDB_WALDIR" "$@"
        fi

        eval 'initdb --username="$POSTGRES_USER" --pwfile=<(echo "$POSTGRES_PASSWORD") '"$POSTGRES_INITDB_ARGS"' "$@"'

        # unset/cleanup "nss_wrapper" bits
        if [ "${LD_PRELOAD:-}" = '/usr/lib/libnss_wrapper.so' ]; then
                rm -f "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"
                unset LD_PRELOAD NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
        fi
}

# print large warning if POSTGRES_PASSWORD is long
# error if both POSTGRES_PASSWORD is empty and POSTGRES_HOST_AUTH_METHOD is not 'trust'
# print large warning if POSTGRES_HOST_AUTH_METHOD is set to 'trust'
# assumes database is not set up, ie: [ -z "$DATABASE_ALREADY_EXISTS" ]
docker_verify_minimum_env() {
        # check password first so we can output the warning before postgres
        # messes it up
        if [ "${#POSTGRES_PASSWORD}" -ge 100 ]; then
                cat >&2 <<-'EOWARN'

                        WARNING: The supplied POSTGRES_PASSWORD is 100+ characters.

                          This will not work if used via PGPASSWORD with "psql".

                          https://www.postgresql.org/message-id/flat/E1Rqxp2-0004Qt-PL%40wrigleys.postgresql.org (BUG #6412)
                          https://github.com/docker-library/postgres/issues/507

                EOWARN
        fi
        if [ -z "$POSTGRES_PASSWORD" ] && [ 'trust' != "$POSTGRES_HOST_AUTH_METHOD" ]; then
                # The - option suppresses leading tabs but *not* spaces. :)
                cat >&2 <<-'EOE'
                        Error: Database is uninitialized and superuser password is not specified.
                               You must specify POSTGRES_PASSWORD to a non-empty value for the
                               superuser. For example, "-e POSTGRES_PASSWORD=password" on "docker run".

                               You may also use "POSTGRES_HOST_AUTH_METHOD=trust" to allow all
                               connections without a password. This is *not* recommended.

                               See PostgreSQL documentation about "trust":
                               https://www.postgresql.org/docs/current/auth-trust.html
                EOE
                exit 1
        fi
        if [ 'trust' = "$POSTGRES_HOST_AUTH_METHOD" ]; then
                cat >&2 <<-'EOWARN'
                        ********************************************************************************
                        WARNING: POSTGRES_HOST_AUTH_METHOD has been set to "trust". This will allow
                                 anyone with access to the Postgres port to access your database without
                                 a password, even if POSTGRES_PASSWORD is set. See PostgreSQL
                                 documentation about "trust":
                                 https://www.postgresql.org/docs/current/auth-trust.html
                                 In Docker's default configuration, this is effectively any other
                                 container on the same system.

                                 It is not recommended to use POSTGRES_HOST_AUTH_METHOD=trust. Replace
                                 it with "-e POSTGRES_PASSWORD=password" instead to set a password in
                                 "docker run".
                        ********************************************************************************
                EOWARN
        fi
}

# usage: docker_process_init_files [file [file [...]]]
#    ie: docker_process_init_files /always-initdb.d/*
# process initializer files, based on file extensions and permissions
docker_process_init_files() {
        # psql here for backwards compatiblilty "${psql[@]}"
        psql=( docker_process_sql )

        echo
        local f
        for f; do
                case "$f" in
                        *.sh)
                                # https://github.com/docker-library/postgres/issues/450#issuecomment-393167936
                                # https://github.com/docker-library/postgres/pull/452
                                if [ -x "$f" ]; then
                                        echo "$0: running $f"
                                        "$f"
                                else
                                        echo "$0: sourcing $f"
                                        . "$f"
                                fi
                                ;;
                        *.sql)    echo "$0: running $f"; docker_process_sql -f "$f"; echo ;;
                        *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | docker_process_sql; echo ;;
                        *.sql.xz) echo "$0: running $f"; xzcat "$f" | docker_process_sql; echo ;;
                        *)        echo "$0: ignoring $f" ;;
                esac
                echo
        done
}

# Execute sql script, passed via stdin (or -f flag of pqsl)
# usage: docker_process_sql [psql-cli-args]
#    ie: docker_process_sql --dbname=mydb <<<'INSERT ...'
#    ie: docker_process_sql -f my-file.sql
#    ie: docker_process_sql <my-file.sql
docker_process_sql() {
        local query_runner=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password )
        if [ -n "$POSTGRES_DB" ]; then
                query_runner+=( --dbname "$POSTGRES_DB" )
        fi

        "${query_runner[@]}" "$@"
}

# create initial database
# uses environment variables for input: POSTGRES_DB
docker_setup_db() {
        if [ "$POSTGRES_DB" != 'postgres' ]; then
                POSTGRES_DB= docker_process_sql --dbname postgres --set db="$POSTGRES_DB" <<-'EOSQL'
                        CREATE DATABASE :"db" ;
                EOSQL
                echo
        fi
}

# Loads various settings that are used elsewhere in the script
# This should be called before any other functions
docker_setup_env() {
        file_env 'POSTGRES_PASSWORD'

        file_env 'POSTGRES_USER' 'postgres'
        file_env 'POSTGRES_DB' "$POSTGRES_USER"
        file_env 'POSTGRES_INITDB_ARGS'
        # default authentication method is md5
        : "${POSTGRES_HOST_AUTH_METHOD:=md5}"

        declare -g DATABASE_ALREADY_EXISTS
        # look specifically for PG_VERSION, as it is expected in the DB dir
        if [ -s "$PGDATA/PG_VERSION" ]; then
                DATABASE_ALREADY_EXISTS='true'
        fi
}

# append POSTGRES_HOST_AUTH_METHOD to pg_hba.conf for "host" connections
pg_setup_hba_conf() {
        {
                echo
                if [ 'trust' = "$POSTGRES_HOST_AUTH_METHOD" ]; then
                        echo '# warning trust is enabled for all connections'
                        echo '# see https://www.postgresql.org/docs/12/auth-trust.html'
                fi
                echo "host all all all $POSTGRES_HOST_AUTH_METHOD"
        } >> "$PGDATA/pg_hba.conf"
}

# start socket-only postgresql server for setting up or running scripts
# all arguments will be passed along as arguments to `postgres` (via pg_ctl)
docker_temp_server_start() {
        if [ "$1" = 'postgres' ]; then
                shift
        fi

        # internal start of server in order to allow setup using psql client
        # does not listen on external TCP/IP and waits until start finishes
        set -- "$@" -c listen_addresses='' -p "${PGPORT:-5432}"

        PGUSER="${PGUSER:-$POSTGRES_USER}" \
        pg_ctl -D "$PGDATA" \
                -o "$(printf '%q ' "$@")" \
                -w start
}

# stop postgresql server after done setting up user and running scripts
docker_temp_server_stop() {
        PGUSER="${PGUSER:-postgres}" \
        pg_ctl -D "$PGDATA" -m fast -w stop
}

# check arguments for an option that would cause postgres to stop
# return true if there is one
_pg_want_help() {
        local arg
        for arg; do
                case "$arg" in
                        # postgres --help | grep 'then exit'
                        # leaving out -C on purpose since it always fails and is unhelpful:
                        # postgres: could not access the server configuration file "/var/lib/postgresql/data/postgresql.conf": No such file or directory
                        -'?'|--help|--describe-config|-V|--version)
                                return 0
                                ;;
                esac
        done
        return 1
}

_main() {
        # if first arg looks like a flag, assume we want to run postgres server
        if [ "${1:0:1}" = '-' ]; then
                set -- postgres "$@"
        fi

        if [ "$1" = 'postgres' ] && ! _pg_want_help "$@"; then
                docker_setup_env
                # setup data directories and permissions (when run as root)
                docker_create_db_directories
                if [ "$(id -u)" = '0' ]; then
                        # then restart script as postgres user
                        exec gosu postgres "$BASH_SOURCE" "$@"
                fi

                # only run initialization on an empty data directory
                if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
                        docker_verify_minimum_env
                        docker_init_database_dir
                        pg_setup_hba_conf

                        # PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
                        # e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
                        export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
                        docker_temp_server_start "$@"

                        docker_setup_db
                        docker_process_init_files /docker-entrypoint-initdb.d/*

                        docker_temp_server_stop
                        unset PGPASSWORD

                        echo
                        echo 'PostgreSQL init process complete; ready for start up.'
                        echo
                else
                        echo
                        echo 'PostgreSQL Database directory appears to contain a database; Skipping initialization'
                        echo
                fi
        fi

        exec "$@"
}

if ! _is_sourced; then
        _main "$@"
fi

```

---

[首 页](https://patrickj-fd.github.io)
