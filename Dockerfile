# Based on manual compile instructions at http://wiki.nginx.org/HttpLuaModule#Installation
FROM ubuntu:14.04

ENV VER_NGINX_DEVEL_KIT 0.3.0
ENV VER_LUA_NGINX_MODULE 0.10.7
ENV VER_NGINX 1.11.10
ENV VER_LUAJIT 2.0.4

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT /nginx
ENV WEB_DIR ${NGINX_ROOT}/html

ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0

ENV NCHAN_VERSION 1.1.1
ENV NCHAN_ROOT nchan-${NCHAN_VERSION}

RUN apt-get -qq update
RUN apt-get -qq -y install wget

# ***** BUILD DEPENDENCIES *****

# Common dependencies (Nginx and LUAJit)
RUN apt-get -qq -y install make
# Nginx dependencies
RUN apt-get -qq -y install libpcre3
RUN apt-get -qq -y install libpcre3-dev
RUN apt-get -qq -y install zlib1g-dev
RUN apt-get -qq -y install libssl-dev
# LUAJit dependencies
RUN apt-get -qq -y install gcc

# ***** DOWNLOAD AND UNTAR *****

# Download
RUN wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz
RUN wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz
RUN wget https://github.com/slact/nchan/archive/v${NCHAN_VERSION}.tar.gz -O ${NCHAN_ROOT}.tar.gz
# Untar
RUN tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz
RUN tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
RUN tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz
RUN tar -xzvf ${NCHAN_ROOT}.tar.gz && rm ${NCHAN_ROOT}.tar.gz

# ***** BUILD FROM SOURCE *****

# LuaJIT
WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make
RUN make install
# Nginx with LuaJIT
WORKDIR /nginx-${VER_NGINX}
RUN ./configure \
    --prefix=${NGINX_ROOT} \
    --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" \
    --add-module=/${NGINX_DEVEL_KIT} \
    --add-module=/${LUA_NGINX_MODULE} \
    --add-module=/${NCHAN_ROOT}

RUN make -j2
RUN make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx

COPY nginx.conf /nginx/conf/nginx.conf

# ***** MISC *****
WORKDIR ${WEB_DIR}

EXPOSE 80 443

# ***** CLEANUP *****
RUN rm -rf /nginx-${VER_NGINX}
RUN rm -rf /LuaJIT-${VER_LUAJIT}
RUN rm -rf /${NGINX_DEVEL_KIT}
RUN rm -rf /${LUA_NGINX_MODULE}
# TODO: Uninstall build only dependencies?
# TODO: Remove env vars used only for build?

# This is the default CMD used by nginx:1.9.2 image
CMD ["nginx", "-g", "daemon off;"]
