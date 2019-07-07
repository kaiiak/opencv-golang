
FROM golang:1.12-alpine3.10 as builder

LABEL maintainer="kaiiak,aNxFi37X@outlook.com"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache ca-certificates \
    && apk add --no-cache git build-base musl-dev alpine-sdk cmake make gcc g++ libc-dev linux-headers

ARG OPENCV_VERSION="4.0.1"
ENV OPENCV_VERSION $OPENCV_VERSION

RUN rm -rf /var/cache/apk/

RUN curl -Lo opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip -q opencv.zip && \
    curl -Lo opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
    unzip -q opencv_contrib.zip && \
    rm opencv.zip opencv_contrib.zip && \
    cd opencv-${OPENCV_VERSION} && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
    -D WITH_JASPER=OFF \
    -D BUILD_DOCS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_opencv_java=NO \
    -D BUILD_opencv_python=NO \
    -D BUILD_opencv_python2=NO \
    -D BUILD_opencv_python3=NO \
    -D OPENCV_GENERATE_PKGCONFIG=ON .. && \
    make -j4 && \
    make preinstall && make install && \
    cd /go && rm -rf opencv*

FROM golang:1.12-alpine3.10

#final stage
FROM golang:1.12-alpine3.10 as opencv
RUN apk --no-cache add ca-certificates gcc
COPY --from=builder /usr/local/lib64 /usr/local/lib64
LABEL maintainer="kaiiak,aNxFi37X@outlook.com"

ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH

