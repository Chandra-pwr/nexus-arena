package repo

import (
	"database/sql"
	"time"

	_ "github.com/lib/pq"
)

type User struct {
	ID                    int64
	Email, Username, Hash string
}
type Repo struct{ db *sql.DB }

func New(dsn string) (*Repo, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}
	for i := 0; i < 30; i++ { // wait for postgres
		if err = db.Ping(); err == nil {
			break
		}
		time.Sleep(time.Second)
	}
	if err != nil {
		return nil, err
	}
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS users(id BIGSERIAL PRIMARY KEY, email TEXT UNIQUE NOT NULL, username TEXT NOT NULL, hash TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT now())`)
	return &Repo{db}, err
}

func (r *Repo) Create(email, username, hash string) (int64, error) {
	var id int64
	err := r.db.QueryRow(`INSERT INTO users(email,username,hash) VALUES($1,$2,$3) RETURNING id`, email, username, hash).Scan(&id)
	return id, err
}

func (r *Repo) ByEmail(email string) (*User, error) {
	u := &User{}
	err := r.db.QueryRow(`SELECT id,email,username,hash FROM users WHERE email=$1`, email).Scan(&u.ID, &u.Email, &u.Username, &u.Hash)
	return u, err
}
