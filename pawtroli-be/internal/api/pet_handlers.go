package api

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"pawtroli-be/internal/models"

	"cloud.google.com/go/firestore"
	"github.com/gorilla/mux"
)

// POST /pets
func CreatePet(w http.ResponseWriter, r *http.Request) {
	log.Println("CreatePet called")
	pet := new(models.Pet)
	if err := json.NewDecoder(r.Body).Decode(pet); err != nil {
		log.Printf("Failed to decode pet: %v", err)
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	log.Printf("Creating pet: %+v", pet)
	pet.CreatedAt = time.Now()

	doc, _, err := firestoreClient.Collection("pets").Add(context.Background(), pet)
	if err != nil {
		log.Printf("Failed to save pet: %v", err)
		http.Error(w, "Error saving pet", http.StatusInternalServerError)
		return
	}
	pet.ID = doc.ID
	log.Printf("Pet created with ID: %s", pet.ID)
	json.NewEncoder(w).Encode(pet)
}

// POST /pets/{petId}/updates
func CreatePetUpdate(w http.ResponseWriter, r *http.Request) {
	petId := mux.Vars(r)["petId"]
	log.Printf("CreatePetUpdate called for petId: %s", petId)
	update := new(models.PetUpdate)
	if err := json.NewDecoder(r.Body).Decode(update); err != nil {
		log.Printf("Failed to decode pet update: %v", err)
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	update.Timestamp = time.Now()
	update.Shared = false

	_, _, err := firestoreClient.Collection("pets").Doc(petId).Collection("updates").Add(context.Background(), update)
	if err != nil {
		log.Printf("Failed to add pet update: %v", err)
		http.Error(w, "Failed to add update", http.StatusInternalServerError)
		return
	}
	log.Printf("Pet update added for petId: %s", petId)
	w.WriteHeader(http.StatusCreated)
}

// GET /pets/{petId}/updates
func GetPetUpdates(w http.ResponseWriter, r *http.Request) {
	petId := mux.Vars(r)["petId"]
	log.Printf("GetPetUpdates called for petId: %s", petId)

	docs, err := firestoreClient.Collection("pets").Doc(petId).Collection("updates").
		OrderBy("timestamp", firestore.Desc).Documents(context.Background()).GetAll()
	if err != nil {
		log.Printf("Failed to fetch pet updates: %v", err)
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

	log.Printf("Fetched %d updates for petId: %s", len(updates), petId)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updates)
}