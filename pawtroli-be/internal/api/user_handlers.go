package api

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"
	"pawtroli-be/internal/models"

	"cloud.google.com/go/firestore"
)

// GET /register
func HandleUserRegister(w http.ResponseWriter, r *http.Request) {
	log.Println("HandleUserRegister called")
	user := new(models.User)
	if err := json.NewDecoder(r.Body).Decode(user); err != nil {
		log.Printf("Failed to decode user: %v", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Printf("Registering user: %+v", user)

	ctx := context.Background()
	docRef := firestoreClient.Collection("users").Doc(user.ID)

	_, err := docRef.Set(ctx, map[string]interface{}{
		"name":      user.Name,
		"email":     user.Email,
		"phone":     user.Phone,
		"role":      user.Role, // "user" or "admin"
		"createdAt": time.Now(),
	}, firestore.MergeAll)
	if err != nil {
		log.Printf("Failed to save user: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	log.Printf("User registered: %s", user.ID)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// SecureEndpointHandler handles authenticated requests to /secure-endpoint
func SecureEndpointHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("SecureEndpointHandler called")
	uid, ok := r.Context().Value("uid").(string)
	if !ok || uid == "" {
		log.Println("Unauthorized access attempt to /secure-endpoint")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	log.Printf("Authenticated user: %s", uid)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": "authenticated",
		"uid":    uid,
	})
}