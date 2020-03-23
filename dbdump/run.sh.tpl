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

for table in ad ad_page attachment_container attachment_file blog_post comment comment_vote context context_route context_route_parameter entity entity_link entity_revision entity_revision_field event event_log event_parameter event_parameter_name event_parameter_string event_parameter_uuid flag instance instance_permission language license metadata metadata_key migrations navigation_container navigation_page navigation_parameter navigation_parameter_key notification notification_event page_repository page_repository_role page_revision permission related_content related_content_category related_content_container related_content_external related_content_internal role role_inheritance role_permission role_user session subscription taxonomy term term_taxonomy term_taxonomy_comment term_taxonomy_entity type url_alias uuid
do
    mysqldump $connect --no-create-info --lock-tables=false --add-locks serlo $table >>dump.sql
done
mysqldump $connect --no-create-info --lock-tables=false --add-locks --where "field = 'interests' and value = 'teacher'" serlo user_field >>dump.sql
mysql $connect --batch -e "SELECT id, concat(@rn:=@rn+1, '@localhost') as email, username, '8a534960a8a4c8e348150a0ae3c7f4b857bfead4f02c8cbf0d' AS password, logins, date, concat(@rn:=@rn+1, '') as token, last_login, NULL as description FROM user, (select @rn:=2) r;" serlo >user.csv

log_info "compress database dump"
rm -f *.zip
zip "dump-$(date -I)".zip dump.sql user.csv >/dev/null

cat << EOF | gcloud auth activate-service-account --key-file=-
${bucket_service_account_key}
EOF
gsutil cp dump-*.zip "${bucket_url}"
log_info "latest dump ${bucket_url} uploaded to serlo-shared"

log_info "dump of serlo.org database - end"
