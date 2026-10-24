package main

import (
	"log"
	"net/http"
	"os"

	"github.com/nexus-arena/auth-service/internal/handler"
	"github.com/nexus-arena/auth-service/internal/repo"
)

func main() {
	r, err := repo.New(os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	mux := http.NewServeMux()
	handler.New(r, os.Getenv("JWT_SECRET")).Routes(mux)
	log.Println("auth-service listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
