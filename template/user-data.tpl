#!/bin/bash -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

if [[ `echo ${user_data_trace_log}` == false ]] 
then
  set -x
fi

# Add current hostname to hosts file
tee /etc/hosts <<EOL
127.0.0.1   localhost localhost.localdomain `hostname`
EOL

for i in {1..7}
do
  echo "Attempt: ---- " $i
  yum -y update  && break || sleep 60
done

${logging}

${gitlab_runner}

apt-get update
apt-get install -y golang-go make git ca-certificates

mkdir /work

export GOPATH=/work
export PATH=$PATH:/usr/local/go/bin

go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login

ls /work/bin

mv /work/bin/docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
chmod +x /usr/local/bin/docker-credential-ecr-login

docker-credential-ecr-login version

echo 798499845229.dkr.ecr.eu-west-1.amazonaws.com | docker-credential-ecr-login get

mkdir -p /.docker
echo > /.docker/config.json '{ "credsStore": "ecr-login" }'

cat /.docker/config.json
