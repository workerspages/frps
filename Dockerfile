FROM alpine:3.18

LABEL maintainer="Stille <stille@ioiox.com>"

# 默认版本，构建时可被覆盖
ARG VERSION=0.65.0
ENV TZ=Asia/Shanghai

WORKDIR /frp

# 安装依赖 & 下载 FRP
# 使用多架构逻辑 (amd64/arm64)
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

# 复制 PaaS 专用配置文件到镜像中
COPY frps_paas.toml /frp/frps.toml

# 声明数据卷 (虽然 PaaS 通常不持久化，但保留此声明是个好习惯)
VOLUME /frp

# 暴露常用端口 (仅作声明，实际以 PaaS 配置为准)
EXPOSE 7000 7500 80 443

# 启动命令
# 注意：不使用 ENTRYPOINT 而是 CMD，方便在 PaaS 面板覆盖启动命令
CMD ["/usr/bin/frps", "-c", "/frp/frps.toml"]
