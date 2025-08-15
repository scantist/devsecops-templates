docker run -d \
  --name gitlab \
  --hostname gitlab.local \
  --restart always \
  --publish 8080:8080 \
  --publish 8022:22 \
  --shm-size 512m \
  -v gitlab_config:/etc/gitlab \
  -v gitlab_logs:/var/log/gitlab \
  -v gitlab_data:/var/opt/gitlab \
  -e GITLAB_OMNIBUS_CONFIG="\
external_url 'http://192.168.0.173:8080';
gitlab_rails['gitlab_shell_ssh_port']=8022;
gitlab_rails['initial_root_password']='ChangeMe_123';
letsencrypt['enable']=false;
puma['listen']='127.0.0.1';
puma['port']=8081;
gitlab_workhorse['auth_backend']='http://127.0.0.1:8081';
gitlab_rails['import_sources'] = ['github', 'bitbucket', 'gitlab', 'gitea', 'git'];
gitlab_rails['omniauth_enabled'] = true;" \
  gitlab/gitlab-ce:latest*-