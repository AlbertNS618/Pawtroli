package api

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/gorilla/mux"

	"pawtroli-be/internal/logger"
)

func AdminRoutes(r *mux.Router) {
	admin := r.PathPrefix("/admin").Subrouter()
	admin.HandleFunc("/logs", GetLogFiles).Methods("GET")
}

// GET /admin/logs - Get list of available log files
func GetLogFiles(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	logger.LogInfo("GetLogFiles called")

	logger.LogInfof("Log files not available - logging to console only")
	logger.LogHTTPRequest(r.Method, r.URL.Path, r.RemoteAddr, http.StatusOK, time.Since(start))

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Logging to console only, no log files available",
		"files":   []string{},
		"count":   0,
	})
}
