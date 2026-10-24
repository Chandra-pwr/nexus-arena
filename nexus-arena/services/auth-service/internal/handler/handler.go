package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"golang.org/x/crypto/bcrypt"

	"github.com/nexus-arena/auth-service/internal/jwt"
	"github.com/nexus-arena/auth-service/internal/repo"
)

type H struct {
	r      *repo.Repo
	secret string
}

func New(r *repo.Repo, secret string) *H { return &H{r, secret} }

type req struct{ Email, Username, Password string }

func out(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(v)
}

func (h *H) Routes(m *http.ServeMux) {
	m.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) { w.Write([]byte("ok")) })
	m.HandleFunc("POST /register", h.register)
	m.HandleFunc("POST /login", h.login)
	m.HandleFunc("GET /me", h.me)
}

func (h *H) register(w http.ResponseWriter, r *http.Request) {
	var q req
	if json.NewDecoder(r.Body).Decode(&q) != nil || q.Email == "" || len(q.Password) < 6 {
		out(w, 400, map[string]string{"error": "email and a 6+ character password are required"})
		return
	}
	if q.Username == "" {
		q.Username = strings.Split(q.Email, "@")[0]
	}
	hash, _ := bcrypt.GenerateFromPassword([]byte(q.Password), bcrypt.DefaultCost)
	id, err := h.r.Create(q.Email, q.Username, string(hash))
	if err != nil {
		out(w, 409, map[string]string{"error": "email already registered"})
		return
	}
	tok, _ := jwt.Sign(h.secret, id, q.Username)
	out(w, 201, map[string]any{"token": tok, "username": q.Username})
}

func (h *H) login(w http.ResponseWriter, r *http.Request) {
	var q req
	json.NewDecoder(r.Body).Decode(&q)
	u, err := h.r.ByEmail(q.Email)
	if err != nil || bcrypt.CompareHashAndPassword([]byte(u.Hash), []byte(q.Password)) != nil {
		out(w, 401, map[string]string{"error": "wrong email or password"})
		return
	}
	tok, _ := jwt.Sign(h.secret, u.ID, u.Username)
	out(w, 200, map[string]any{"token": tok, "username": u.Username})
}

func (h *H) me(w http.ResponseWriter, r *http.Request) {
	c, err := jwt.Parse(h.secret, strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer "))
	if err != nil {
		out(w, 401, map[string]string{"error": "invalid token"})
		return
	}
	out(w, 200, c)
}
