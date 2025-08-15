#####  Only after the gitlab is up, fix the ip for project clone default url
# check what GitLab is set to
docker exec -it gitlab bash -lc "grep -n '^external_url' /etc/gitlab/gitlab.rb"

# if you see localhost, set it to your LAN IP and apply
docker exec -it gitlab bash -lc "\
sed -i \"s|^external_url .*|external_url 'http://192.168.0.173:8080'|\" /etc/gitlab/gitlab.rb && \
gitlab-ctl reconfigure && \
gitlab-ctl restart"