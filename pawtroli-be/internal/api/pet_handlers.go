package api

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"pawtroli-be/internal/logger"
	"pawtroli-be/internal/models"

	"github.com/gorilla/mux"
	"google.golang.org/api/iterator"
)

// POST /pets
func CreatePet(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	logger.LogInfo("CreatePet called")

	pet := new(models.Pet)
	if err := json.NewDecoder(r.Body).Decode(pet); err != nil {
		logger.LogErrorf("Failed to decode pet: %v", err)
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	logger.LogInfof("Creating pet: %+v", pet)
	pet.CreatedAt = time.Now()

	doc, _, err := firestoreClient.Collection("pets").Add(context.Background(), pet)
	duration := time.Since(start)
	if err != nil {
		logger.LogErrorf("Failed to save pet: %v", err)
		logger.LogFirestoreOperation("CREATE", "pets", "", false, duration)
		http.Error(w, "Error saving pet", http.StatusInternalServerError)
		return
	}
	pet.ID = doc.ID
	logger.LogInfof("Pet created with ID: %s", pet.ID)
	logger.LogFirestoreOperation("CREATE", "pets", pet.ID, true, duration)
	logger.LogHTTPRequest(r.Method, r.URL.Path, r.RemoteAddr, http.StatusOK, time.Since(start))
	err = json.NewEncoder(w).Encode(pet)
	if err != nil {
		return
	}
}

// POST /pets/{petId}/updates
func CreatePetUpdate(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	petId := mux.Vars(r)["petId"]
	logger.LogInfof("CreatePetUpdate called for petId: %s", petId)

	update := new(models.PetUpdate)
	if err := json.NewDecoder(r.Body).Decode(update); err != nil {
		logger.LogErrorf("Failed to decode pet update: %v", err)
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	update.Timestamp = time.Now()

	_, _, err := firestoreClient.Collection("pets").Doc(petId).Collection("updates").Add(context.Background(), update)
	duration := time.Since(start)
	if err != nil {
		logger.LogErrorf("Failed to add pet update: %v", err)
		logger.LogFirestoreOperation("CREATE", "pets/"+petId+"/updates", "", false, duration)
		http.Error(w, "Failed to add update", http.StatusInternalServerError)
		return
	}
	logger.LogInfof("Pet update added for petId: %s", petId)
	logger.LogFirestoreOperation("CREATE", "pets/"+petId+"/updates", "", true, duration)
	logger.LogHTTPRequest(r.Method, r.URL.Path, r.RemoteAddr, http.StatusCreated, time.Since(start))
	w.WriteHeader(http.StatusCreated)
}

// GET /pets/{petId}/updates
func GetPetUpdates(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	petId := mux.Vars(r)["petId"]
	logger.LogInfof("GetPetUpdates called for petId: %s", petId)

	ctx := context.Background()
	iter := firestoreClient.Collection("pet_updates").Where("petId", "==", petId).Documents(ctx)
	defer iter.Stop()

	var updates []models.PetUpdate
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			logger.LogErrorf("Error fetching pet updates: %v", err)
			http.Error(w, "Failed to fetch updates", http.StatusInternalServerError)
			return
		}
		var update models.PetUpdate
		if err := doc.DataTo(&update); err != nil {
			logger.LogErrorf("Error decoding pet update: %v", err)
			continue
		}
		update.ID = doc.Ref.ID
		updates = append(updates, update)
		logger.LogInfof("Fetched update: %+v", update)
	}
	print("updates: ", updates)
	logger.LogInfof("Fetched %d updates for petId: %s", len(updates), petId)
	logger.LogHTTPRequest(r.Method, r.URL.Path, r.RemoteAddr, http.StatusOK, time.Since(start))
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updates)
}
