package main

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"
)

var (
	mu    sync.Mutex
	items = []map[string]any{}
)

func main() {
	m := http.NewServeMux()
	m.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) { w.Write([]byte("ok")) })
	m.HandleFunc("/queue", func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		defer mu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		if r.Method == http.MethodPost {
			var v map[string]any
			if json.NewDecoder(r.Body).Decode(&v) != nil {
				http.Error(w, `{"error":"bad json"}`, 400)
				return
			}
			v["at"] = time.Now().Unix()
			items = append(items, v)
			w.WriteHeader(201)
		}
		json.NewEncoder(w).Encode(items)
	})
	log.Println("matchmaking-service listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", m))
}
