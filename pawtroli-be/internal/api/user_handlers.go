package api

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"pawtroli-be/internal/models"
	"time"

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

// SecureEndpointHandler handles authenticated requests to /login
func SecureEndpointHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("SecureEndpointHandler called: method=%s, url=%s, remoteAddr=%s, headers=%v",
		r.Method, r.URL.Path, r.RemoteAddr, r.Header)
	uid, ok := r.Context().Value("uid").(string)
	log.Print("User ID from context:", uid)
	if !ok || uid == "" {
		log.Println("Unauthorized access attempt to /login")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	// Fetch user data from Firestore
	ctx := context.Background()
	doc, err := firestoreClient.Collection("users").Doc(uid).Get(ctx)
	if err != nil {
		log.Printf("Failed to get user data: %v", err)
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}
	data := doc.Data()

	name, _ := data["name"].(string)
	email, _ := data["email"].(string)
	phone, _ := data["phone"].(string)
	role, _ := data["role"].(string)

	log.Printf("Authenticated user: %s", uid)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": "authenticated",
		"uid":    uid,
		"name":   name,
		"email":  email,
		"phone":  phone,
		"role":   role,
	})
}
