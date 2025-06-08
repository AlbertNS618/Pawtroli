package middleware

import (
	"context"
	"log"
	"net/http"
	"strings"
	"time"

	"pawtroli-be/internal/firebase"
)

func VerifyToken(next http.Handler) http.Handler {
	log.Println("VerifyToken middleware initialized")
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Println("VerifyToken middleware called")
		start := time.Now()
		authHeader := r.Header.Get("Authorization")
		log.Printf("VerifyToken: Authorization header: %s", authHeader)
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			log.Println("VerifyToken: Missing or invalid Authorization header")
			http.Error(w, "Missing auth token", http.StatusUnauthorized)
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		ctx := context.Background()
		client, err := firebase.App.Auth(ctx)
		if err != nil {
			log.Printf("VerifyToken: Failed to get auth client: %v", err)
			http.Error(w, "Failed to get auth client", http.StatusInternalServerError)
			return
		}

		token, err := client.VerifyIDToken(ctx, tokenStr)
		if err != nil {
			log.Printf("VerifyToken: Invalid token: %v", err)
			http.Error(w, "Invalid token", http.StatusUnauthorized)
			return
		}

		log.Printf("VerifyToken: Authenticated UID: %s (verification took %v)", token.UID, time.Since(start))
		ctx = context.WithValue(r.Context(), "uid", token.UID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
