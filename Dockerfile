FROM golang:alpine
ADD . ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /main

FROM scratch
COPY --from=0 /main /
ENV PORT 8080
EXPOSE 8080
ENTRYPOINT ["/main"]
