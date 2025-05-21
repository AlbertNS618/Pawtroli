package main

import (
	"log"
	"net/http"

	"pawtroli-be/internal/api"
	"pawtroli-be/internal/firebase"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

func main() {
	firebase.InitFirebase()
	api.InitHandlers()

	r := mux.NewRouter()

	// Routes
	r.HandleFunc("/login", api.HandleUserLogin).Methods("POST")
	r.HandleFunc("/pets", api.CreatePet).Methods("POST")
	r.HandleFunc("/pets/{petId}/updates", api.CreatePetUpdate).Methods("POST")
	r.HandleFunc("/pets/{petId}/updates", api.GetPetUpdates).Methods("GET")

	// Add CORS middleware
	corsHandler := handlers.CORS(
		handlers.AllowedOrigins([]string{"*"}), // Change "*" to your frontend URL for production
		handlers.AllowedMethods([]string{"GET", "POST", "OPTIONS"}),
		handlers.AllowedHeaders([]string{"Authorization", "Content-Type"}),
	)(r)

	log.Println("🚀 Server running on :8080")
	log.Fatal(http.ListenAndServe("0.0.0.0:8080", corsHandler))
}
