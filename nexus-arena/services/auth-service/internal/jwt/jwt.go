package jwt

import (
	"time"

	gojwt "github.com/golang-jwt/jwt/v5"
)

func Sign(secret string, uid int64, name string) (string, error) {
	c := gojwt.MapClaims{"sub": uid, "name": name, "exp": time.Now().Add(24 * time.Hour).Unix()}
	return gojwt.NewWithClaims(gojwt.SigningMethodHS256, c).SignedString([]byte(secret))
}

func Parse(secret, tok string) (gojwt.MapClaims, error) {
	t, err := gojwt.Parse(tok, func(*gojwt.Token) (any, error) { return []byte(secret), nil },
		gojwt.WithValidMethods([]string{"HS256"}))
	if err != nil {
		return nil, err
	}
	return t.Claims.(gojwt.MapClaims), nil
}
