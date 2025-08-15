docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v gitlab_runner_config:/etc/gitlab-runner \
  gitlab/gitlab-runner:alpine


export GL_URL=http://192.168.0.173:8080
export GL_TOKEN=glrt-REPLACE_WITH_YOURS

docker exec -it gitlab-runner gitlab-runner register --non-interactive \
  --url "$GL_URL" \
  --registration-token "$GL_TOKEN" \
  --executor docker \
  --docker-image alpine:3.20 \
  --description "local-docker-runner" \
  --tag-list "docker" \
  --run-untagged=true \
  --locked=false