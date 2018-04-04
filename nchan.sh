cd /

export VER_NGINX_DEVEL_KIT="0.3.0"
export VER_LUA_NGINX_MODULE="0.10.7"
export VER_NGINX="1.11.10"
export VER_LUAJIT="2.0.4"

export NGINX_DEVEL_KIT="ngx_devel_kit-$VER_NGINX_DEVEL_KIT"
export LUA_NGINX_MODULE="lua-nginx-module-$VER_LUA_NGINX_MODULE"
export NGINX_ROOT="/nginx"
export WEB_DIR="$NGINX_ROOT/html"

export LUAJIT_LIB="/usr/local/lib"
export LUAJIT_INC="/usr/local/include/luajit-2.0"

export NCHAN_VERSION="1.1.1"
export NCHAN_ROOT="nchan-$NCHAN_VERSION"

apt-get -qq update
apt-get -qq -y install wget

# ***** BUILD DEPENDENCIES *****

# Common dependencies (Nginx and LUAJit)
apt-get -qq -y install make
# Nginx dependencies
apt-get -qq -y install libpcre3
apt-get -qq -y install libpcre3-dev
apt-get -qq -y install zlib1g-dev
apt-get -qq -y install libssl-dev
# LUAJit dependencies
apt-get -qq -y install gcc

# ***** DOWNLOAD AND UNTAR *****

# Download
wget http://nginx.org/download/nginx-$VER_NGINX.tar.gz
wget http://luajit.org/download/LuaJIT-$VER_LUAJIT.tar.gz
wget https://github.com/simpl/ngx_devel_kit/archive/v$VER_NGINX_DEVEL_KIT.tar.gz -O $NGINX_DEVEL_KIT.tar.gz
wget https://github.com/openresty/lua-nginx-module/archive/v$VER_LUA_NGINX_MODULE.tar.gz -O $LUA_NGINX_MODULE.tar.gz
wget https://github.com/slact/nchan/archive/v$NCHAN_VERSION.tar.gz -O $NCHAN_ROOT.tar.gz
# Untar
tar -xzvf nginx-$VER_NGINX.tar.gz && rm nginx-$VER_NGINX.tar.gz
tar -xzvf LuaJIT-$VER_LUAJIT.tar.gz && rm LuaJIT-$VER_LUAJIT.tar.gz
tar -xzvf $NGINX_DEVEL_KIT.tar.gz && rm $NGINX_DEVEL_KIT.tar.gz
tar -xzvf $LUA_NGINX_MODULE.tar.gz && rm $LUA_NGINX_MODULE.tar.gz
tar -xzvf $NCHAN_ROOT.tar.gz && rm $NCHAN_ROOT.tar.gz

# ***** BUILD FROM SOURCE *****

# LuaJIT
cd /LuaJIT-$VER_LUAJIT
make
make install
# Nginx with LuaJIT
cd /nginx-$VER_NGINX
./configure \
  --prefix=$NGINX_ROOT \
  --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" \
  --add-module=/$NGINX_DEVEL_KIT \
  --add-module=/$LUA_NGINX_MODULE \
  --add-module=/$NCHAN_ROOT

make -j2
make install
ln -s $NGINX_ROOT/sbin/nginx /usr/local/sbin/nginx

# ***** MISC *****
cd $WEB_DIR

# ***** CLEANUP *****
rm -rf /nginx-$VER_NGINX
rm -rf /LuaJIT-$VER_LUAJIT
rm -rf /$NGINX_DEVEL_KIT
rm -rf /$LUA_NGINX_MODULE
# TODO: Uninstall build only dependencies?
# TODO: Remove env vars used only for build?
