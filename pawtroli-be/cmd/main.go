package main

import (
	"log"
	"net/http"

	"pawtroli-be/internal/api"
	"pawtroli-be/internal/firebase"
	"pawtroli-be/internal/middleware"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

func registerPetRoutes(r *mux.Router) {
	pets := r.PathPrefix("/pets").Subrouter()
	pets.HandleFunc("", api.CreatePet).Methods("POST")
	pets.HandleFunc("/{petId}/updates", api.CreatePetUpdate).Methods("POST")
	pets.HandleFunc("/{petId}/updates", api.GetPetUpdates).Methods("GET")
}

func registerChatRoutes(r *mux.Router) {
	chats := r.PathPrefix("/chats").Subrouter()
	chats.HandleFunc("", api.CreateChatRoom).Methods("POST")
	chats.HandleFunc("/{roomId}/messages", api.SendMessage).Methods("POST")
	chats.HandleFunc("/{roomId}/messages", api.GetMessages).Methods("GET")
}

func main() {
	firebase.InitFirebase()
	api.InitHandlers()

	r := mux.NewRouter()

	// Routes
	r.HandleFunc("/register", api.HandleUserRegister).Methods("POST")
	registerPetRoutes(r)
	registerChatRoutes(r)
	r.Handle("/secure-endpoint", middleware.VerifyToken(http.HandlerFunc(api.SecureEndpointHandler))).Methods("POST")

	// Add CORS middleware
	corsHandler := handlers.CORS(
		handlers.AllowedOrigins([]string{"*"}), // Change "*" to your frontend URL for production
		handlers.AllowedMethods([]string{"GET", "POST", "OPTIONS"}),
		handlers.AllowedHeaders([]string{"Authorization", "Content-Type"}),
	)(r)

	log.Println("🚀 Server running on :8080")
	log.Fatal(http.ListenAndServe("0.0.0.0:8080", corsHandler))
}
