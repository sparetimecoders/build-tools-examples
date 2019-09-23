FROM golang:1.13 as go-build
WORKDIR /build
ADD . /build

RUN GOOS=linux GOARCH=amd64 go build \
        -tags prod \
        -a -installsuffix cgo \
        -o /release/example \
        -ldflags="-s -w" \
        main.go

FROM scratch
COPY --from=go-build /release/example /example

ENTRYPOINT ["/example"]