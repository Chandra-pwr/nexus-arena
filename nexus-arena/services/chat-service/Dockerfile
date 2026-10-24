FROM golang:1.22-alpine AS b
WORKDIR /src
COPY . .
RUN go mod tidy && CGO_ENABLED=0 go build -o /out/app ./cmd/server
FROM gcr.io/distroless/static
COPY --from=b /out/app /app
USER 65532
EXPOSE 8080
ENTRYPOINT ["/app"]
