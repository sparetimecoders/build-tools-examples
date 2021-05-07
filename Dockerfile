FROM golang:1.16 as build
WORKDIR /build
ENV CGO_ENABLED=1
ADD . /build

RUN if [ $(go mod tidy -v 2>&1 | grep -c unused) != 0 ]; then echo "Unused modules, please run 'go mod tidy'"; exit 1; fi
RUN test -z $(go fmt ./...)
RUN test -z $(go vet ./...)

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh && ./bin/golangci-lint run


RUN go test -mod=readonly -race -coverprofile=coverage.txt.tmp -covermode=atomic -coverpkg=$(go list ./... | tr '\n' , | sed 's/,$//') ./...
RUN ["/bin/bash", "-c", "cat coverage.txt.tmp | grep -v -f <(find . -type f | xargs grep -l 'Code generated') > coverage.txt"]
RUN go tool cover -html=coverage.txt -o coverage.html
RUN go tool cover -func=coverage.txt
RUN rm coverage.txt.tmp

RUN GOOS=linux GOARCH=amd64 go build \
        -tags prod \
        -a -installsuffix cgo \
        -mod=readonly \
        -o /release/service \
         -ldflags '-w -s' \
         ./cmd/service/service.go

FROM debian:buster-slim
COPY --from=build /release/service /
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo

CMD ["/service"]