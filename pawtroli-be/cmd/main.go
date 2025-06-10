package main

import (
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"pawtroli-be/internal/api"
	"pawtroli-be/internal/firebase"
	"pawtroli-be/internal/logger"
	"pawtroli-be/internal/middleware"
	"pawtroli-be/internal/services"

	// "github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

func registerAdminRoutes(r *mux.Router) {
	admin := r.PathPrefix("/admin").Subrouter()
	admin.HandleFunc("/logs", api.GetLogFiles).Methods("GET")
}

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
	// Initialize logger first
	if err := logger.InitLogger(); err != nil {
		panic("Failed to initialize logger: " + err.Error())
	}
	defer logger.CloseLogger()

	// Initialize log rotation service
	// Keep logs for 30 days, maximum 50 files
	logRotationService := services.NewLogRotationService("logs", 50, 30*24*time.Hour)
	logRotationService.Start()
	defer logRotationService.Stop()

	// Setup graceful shutdown
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		logger.LogInfo("Shutting down server...")
		logRotationService.Stop()
		logger.CloseLogger()
		os.Exit(0)
	}()

	logger.LogInfo("Starting Pawtroli Backend Server...")

	firebase.InitFirebase()
	api.InitHandlers()

	// Pass log rotation service to API handlers
	api.SetLogRotationService(logRotationService)

	r := mux.NewRouter()

	// Add logging middleware to all routes
	r.Use(middleware.LoggingMiddleware)

	// Routes
	r.HandleFunc("/register", api.HandleUserRegister).Methods("POST")
	registerPetRoutes(r)
	registerChatRoutes(r)
	registerAdminRoutes(r)
	r.Handle("/login", middleware.VerifyToken(http.HandlerFunc(api.SecureEndpointHandler))).Methods("POST")

	logger.LogInfo("🚀 Server running on :8080")
	err := http.ListenAndServe("0.0.0.0:8080", r)
	if err != nil {
		return
	}
}
