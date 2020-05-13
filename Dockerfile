FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HEIMDALL_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

ENV HOME="/app/heimdall"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	g++ \
	make \
	python3 && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	nodejs \
	npm && \
 echo "**** install heimdalljs ****" && \
 mkdir -p /app/heimdall && \
 if [ -z ${HEIMDALL_RELEASE+x} ]; then \
	HEIMDALL_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/heimdalljs/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 	/tmp/heimdalljs.tar.gz -L \
	"https://github.com/linuxserver/heimdalljs/archive/${HEIMDALL_RELEASE}.tar.gz" && \
 tar xf \
 	/tmp/heimdalljs.tar.gz -C \
	/app/heimdall/ --strip-components=1 && \
 cd /app/heimdall && \
 npm install && \
 cp .env.example .env && \
 NODE_ENV=production npm run build && \
 echo "**** cleanup ****" && \
 npm prune --production && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

ENV NODE_ENV="production"

# copy local files
COPY root/ /
