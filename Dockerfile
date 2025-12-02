FROM alpine:3.18

LABEL maintainer="Stille <stille@ioiox.com>"

ARG VERSION=0.65.0
ENV TZ=Asia/Shanghai

# =========================================================
# 设置默认环境变量 (关键修复)
# 如果 Zeabur 没有设置这些变量，这里的值将作为默认值生效
# =========================================================
ENV FRP_BIND_PORT=7000
ENV FRP_HTTP_PORT=80
ENV FRP_HTTPS_PORT=443
ENV FRP_DASHBOARD_PORT=7500
ENV FRP_DASHBOARD_USER=admin
ENV FRP_DASHBOARD_PWD=admin
ENV FRP_ALLOW_PORT_START=1000
ENV FRP_ALLOW_PORT_END=60000
ENV FRP_MAX_PORTS=8
# FRP_AUTH_TOKEN 不设置默认值，强制要求在平台填写，或者留空(不推荐)
ENV FRP_AUTH_TOKEN="" 

WORKDIR /frp

RUN apk add --no-cache tzdata ca-certificates wget \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && \
    if [ "$(uname -m)" = "x86_64" ]; then export PLATFORM=amd64 ; \
    elif [ "$(uname -m)" = "aarch64" ]; then export PLATFORM=arm64 ; \
    else export PLATFORM=arm ; fi \
    && wget --no-check-certificate https://github.com/fatedier/frp/releases/download/v${VERSION}/frp_${VERSION}_linux_${PLATFORM}.tar.gz \
    && tar xzf frp_${VERSION}_linux_${PLATFORM}.tar.gz \
    && mv frp_${VERSION}_linux_${PLATFORM}/frps /usr/bin/frps \
    && rm -rf *.tar.gz frp_${VERSION}_linux_${PLATFORM} \
    && apk del wget

COPY frps_paas.toml /frp/frps.toml

VOLUME /frp

EXPOSE 7000 7500 80 443

CMD ["/usr/bin/frps", "-c", "/frp/frps.toml"]
