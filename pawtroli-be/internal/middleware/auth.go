package middleware

import (
	"context"
	"net/http"
	"strings"

	// "firebase.google.com/go/auth"
	"github.com/gin-gonic/gin"
	"pawtroli-be/internal/firebase"
)

func AuthMiddleware() gin.HandlerFunc {
	client, _ := firebase.App.Auth(context.Background())

	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header"})
			c.Abort()
			return
		}
		idToken := strings.TrimPrefix(authHeader, "Bearer ")

		if idToken == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing token"})
			c.Abort()
			return
		}

		_, err := client.VerifyIDToken(context.Background(), idToken)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		c.Next()
	}
}

func VerifyToken(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
            http.Error(w, "Missing auth token", http.StatusUnauthorized)
            return
        }

        tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
        ctx := context.Background()
        client, err := firebase.App.Auth(ctx)
        if err != nil {
            http.Error(w, "Failed to get auth client", http.StatusInternalServerError)
            return
        }

        token, err := client.VerifyIDToken(ctx, tokenStr)
        if err != nil {
            http.Error(w, "Invalid token", http.StatusUnauthorized)
            return
        }

        ctx = context.WithValue(r.Context(), "uid", token.UID)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
