#!/bin/sh

set -e

log_info() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"info\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_fatal() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"fatal\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_warn() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"warn\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_info "run serlo.org dbdump"

connect="--host=${database_host} --port=${database_port} --user=${database_username} --password=${database_password}"

set +e
mysql $connect -e "SHOW DATABASES; USE ${database_name}; SHOW TABLES;" | grep uuid >/dev/null 2>/dev/null
if [[ $? != 0 ]] ; then
    log_info "database ${database_name} does not exist; nothing to dump"
    exit 0
fi
set -e

cd /tmp

log_info "dump serlo.org database - start"
log_info "dump database schema"

mysqldump $connect --no-data --lock-tables=false --add-drop-database serlo >dump.sql

log_info "dump database data"
mysqldump $connect --no-create-info --lock-tables=false --add-locks --ignore-table=serlo.session serlo >> dump.sql

log_info "anonymize database dump"
sed -i -r "/([0-9]+, ?)'[^']+\@[^']+',( ?'[^']+', ?)'[^']+',( ?[0-9]+, ?'[^']+', ?)'[^']+'/ s//\1CONCAT\(LEFT\(UUID\(\), 8\),'@localhost'\),\2'8a534960a8a4c8e348150a0ae3c7f4b857bfead4f02c8cbf0d',\3LEFT\(UUID\(\), 8\)/" dump.sql

log_info "compress database dump"
rm -f *.zip
zip "dump-$(date -I)".zip dump.sql >/dev/null

cat << EOF | gcloud auth activate-service-account --key-file=-
${bucket_service_account_key}
EOF
gsutil cp dump-*.zip "${bucket_url}"
log_info "latest dump ${bucket_url} uploaded to serlo-shared"

log_info "dump of serlo.org database - end"
