#/usr/bin/env sh

# middleman-deploy with sftp is messed up for me so ¯\_(ツ)_/¯
# The assets aren't being copied and if I update I get a message about
# deploy being an extension is no longer supported.

rm -rf build
bundle exec middleman build

mkdir -p ./tmp
rm tmp/*
cd build

tar -czvf ../tmp/cultivatehq.tar.gz *

filename="$(date +"%Y_%m_%d_%H_%M_%S").tar.gz"

scp ../tmp/cultivatehq.tar.gz static@cultivatehq.com:$filename  && \
ssh static@cultivatehq.com "rm -rf cultivatehq.com &&  \
    mkdir -p cultivatehq.com && \
    cd cultivatehq.com && \
    tar -zxvf ../$filename"
