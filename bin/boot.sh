# ------------------------------------------------------------------------------------------------
# Copyright 2013 Jordon Bedwell.
# Apache License.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
# except  in compliance with the License. You may obtain a copy of the License at:
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the
# License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions
# and  limitations under the License.
# ------------------------------------------------------------------------------------------------
# compile_nginx_download=https://d35wldypfbhn1h.cloudfront.net/nginx-1.4.1.tar.gz

# ------------------------------------------------------------------------------------------------

# compile_build_dir=$1
# compile_cache_dir=$2
# compile_buildpack_dir=$(cd $(dirname $0) && cd .. && pwd)
# compile_buildpack_bin=$compile_buildpack_dir/bin

#echo "pwd: $(pwd)"
#echo "compile_build_dir: $compile_build_dir"
#echo "compile_cache_dir: $compile_cache_dir"
#echo "compile_buildpack_bin: $compile_buildpack_bin"
#echo "compile_buildpack_dir: $compile_buildpack_dir"

# ------------------------------------------------------------------------------------------------

cd $compile_build_dir

# ------------------------------------------------------------------------------------------------

echo "-----> Doing work with $(basename ${compile_nginx_download%.tar.gz}) son."
mkdir -p $compile_cache_dir/public
mv * $compile_cache_dir/public
mv $compile_cache_dir/public .
[[ -f public/Procfile ]] && mv public/Procfile .
curl -s --max-time 60 $compile_nginx_download |tar xz

cp -f $compile_buildpack_dir/conf/nginx.conf nginx/conf/nginx.conf
cp -f $compile_buildpack_dir/conf/mime.types nginx/conf/mime.types

[[ -f public/nginx.conf ]] && mv public/nginx.conf nginx/conf/nginx.conf
[[ -f public/mime.types ]] && mv public/mime.types nginx/conf/mime.types

echo "-----> Ensuring manifest.yml & stackato.yml aren't available in public/"
rm -f public/{manifest,stackato}.yml





export APP_ROOT=$HOME

conf_file=$APP_ROOT/nginx/conf/nginx.conf
if [ -f $APP_ROOT/public/nginx.conf ]
then
  conf_file=$APP_ROOT/public/nginx.conf
fi

mv $conf_file $APP_ROOT/nginx/conf/orig.conf
erb $APP_ROOT/nginx/conf/orig.conf > $APP_ROOT/nginx/conf/nginx.conf

# ------------------------------------------------------------------------------------------------

(tail -f -n 0 $APP_ROOT/nginx/logs/*.log &)
exec $APP_ROOT/nginx/sbin/nginx -p $APP_ROOT/nginx -c $APP_ROOT/nginx/conf/nginx.conf

# ------------------------------------------------------------------------------------------------
