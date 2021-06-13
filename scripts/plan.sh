#!/bin/sh
DIRS=$(git --no-pager diff origin/develop..HEAD --name-only | xargs -I {} dirname {} | grep "terraform" | uniq)
if [ -z "$DIRS" ]; then
  echo "No directories for apply."
  exit 0
fi

for dir in $DIRS
do
  if [ ! -e $dir/terraform.tf ]; then
    continue
  fi

  echo $dir
  (cd $dir && terraform init -input=false -no-color)
  (cd $dir && terraform plan -input=false -no-color)
done