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