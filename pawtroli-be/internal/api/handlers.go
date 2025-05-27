package api

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"pawtroli-be/internal/firebase"
	"pawtroli-be/internal/models"

	"cloud.google.com/go/firestore"
	"github.com/gorilla/mux"
)

var firestoreClient *firestore.Client

func InitHandlers() {
	ctx := context.Background()
	client, err := firebase.App.Firestore(ctx)
	if err != nil {
		log.Fatalf("❌ Failed to init Firestore: %v", err)
	}
	firestoreClient = client
}

// GET /register
func HandleUserRegister(w http.ResponseWriter, r *http.Request) {
	user := new(models.User)
	if err := json.NewDecoder(r.Body).Decode(user); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	ctx := context.Background()
	docRef := firestoreClient.Collection("users").Doc(user.ID)

	_, err := docRef.Set(ctx, map[string]interface{}{
		"name":      user.Name,
		"email":     user.Email,
		"phone":     user.Phone,
		"createdAt": time.Now(),
	}, firestore.MergeAll)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// SecureEndpointHandler handles authenticated requests to /secure-endpoint
func SecureEndpointHandler(w http.ResponseWriter, r *http.Request) {
	uid, ok := r.Context().Value("uid").(string)
	if !ok || uid == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": "authenticated",
		"uid":    uid,
	})
}

// POST /pets
func CreatePet(w http.ResponseWriter, r *http.Request) {
	pet := new(models.Pet)
	if err := json.NewDecoder(r.Body).Decode(pet); err != nil {
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	pet.CreatedAt = time.Now()

	doc, _, err := firestoreClient.Collection("pets").Add(context.Background(), pet)
	if err != nil {
		http.Error(w, "Error saving pet", http.StatusInternalServerError)
		return
	}
	pet.ID = doc.ID
	json.NewEncoder(w).Encode(pet)
}

// POST /pets/{petId}/updates
func CreatePetUpdate(w http.ResponseWriter, r *http.Request) {
	petId := mux.Vars(r)["petId"]
	update := new(models.PetUpdate)
	if err := json.NewDecoder(r.Body).Decode(update); err != nil {
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	update.Timestamp = time.Now()
	update.Shared = false

	_, _, err := firestoreClient.Collection("pets").Doc(petId).Collection("updates").Add(context.Background(), update)
	if err != nil {
		http.Error(w, "Failed to add update", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

// GET /pets/{petId}/updates
func GetPetUpdates(w http.ResponseWriter, r *http.Request) {
	petId := mux.Vars(r)["petId"]

	docs, err := firestoreClient.Collection("pets").Doc(petId).Collection("updates").
		OrderBy("timestamp", firestore.Desc).Documents(context.Background()).GetAll()
	if err != nil {
		http.Error(w, "Failed to fetch updates", http.StatusInternalServerError)
		return
	}

	var updates []*models.PetUpdate
	for _, doc := range docs {
		u := new(models.PetUpdate)
		doc.DataTo(u)
		u.ID = doc.Ref.ID
		updates = append(updates, u)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updates)
}
