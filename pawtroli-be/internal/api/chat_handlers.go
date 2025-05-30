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
	log.Println("✅ Firestore client initialized")
}

// POST /chats/{roomId}
func CreateChatRoom(w http.ResponseWriter, r *http.Request) {
	roomId := mux.Vars(r)["roomId"]
	log.Printf("CreateChatRoom called for roomId: %s", roomId)
	room := new(models.ChatRoom)
	if err := json.NewDecoder(r.Body).Decode(room); err != nil {
		log.Printf("Failed to decode chat room: %v", err)
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	room.CreatedAt = time.Now()

	// Check if chat room already exists
	docRef := firestoreClient.Collection("chats").Doc(roomId)
	docSnap, err := docRef.Get(context.Background())
	if err == nil && docSnap.Exists() {
		log.Printf("Chat room already exists: %s", roomId)
		room.ID = roomId
		json.NewEncoder(w).Encode(room)
		return
	}

	_, err = docRef.Set(context.Background(), room)
	if err != nil {
		log.Printf("Failed to create chat room: %v", err)
		http.Error(w, "Error creating chat room", http.StatusInternalServerError)
		return
	}
	room.ID = roomId
	log.Printf("Chat room created: %s", roomId)
	json.NewEncoder(w).Encode(room)
}

// POST /chats/{roomId}/messages
func SendMessage(w http.ResponseWriter, r *http.Request) {
	roomId := mux.Vars(r)["roomId"]
	log.Printf("SendMessage called for roomId: %s", roomId)
	msg := new(models.Message)
	if err := json.NewDecoder(r.Body).Decode(msg); err != nil {
		log.Printf("Failed to decode message: %v", err)
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	msg.Timestamp = time.Now()
	msg.RoomID = roomId

	doc, _, err := firestoreClient.Collection("chats").Doc(roomId).Collection("messages").Add(context.Background(), msg)
	if err != nil {
		log.Printf("Failed to send message: %v", err)
		http.Error(w, "Error sending message", http.StatusInternalServerError)
		return
	}
	msg.ID = doc.ID
	log.Printf("Message sent with ID: %s in roomId: %s", msg.ID, roomId)
	json.NewEncoder(w).Encode(msg)
}

type MessageResponse struct {
	ID        string `json:"id"`
	Content   string `json:"content"`
	SenderID  string `json:"senderId"`
	RoomID    string `json:"roomId"`
	Timestamp string `json:"timestamp"`
}

// GET /chats/{roomId}/messages
func GetMessages(w http.ResponseWriter, r *http.Request) {
	roomId := mux.Vars(r)["roomId"]
	log.Printf("GetMessages called for roomId: %s", roomId)
	docs, err := firestoreClient.Collection("chats").Doc(roomId).Collection("messages").OrderBy("timestamp", firestore.Asc).Documents(context.Background()).GetAll()
	if err != nil {
		log.Printf("Failed to fetch messages: %v", err)
		http.Error(w, "Failed to fetch messages", http.StatusInternalServerError)
		return
	}

	loc, _ := time.LoadLocation("Asia/Jakarta") // UTC+7

	var messages []MessageResponse
	for _, doc := range docs {
		m := new(models.Message)
		doc.DataTo(m)
		m.ID = doc.Ref.ID
		// Convert timestamp to UTC+7 before formatting
		messages = append(messages, MessageResponse{
			ID:        m.ID,
			Content:   m.Content,
			SenderID:  m.SenderID,
			RoomID:    m.RoomID,
			Timestamp: m.Timestamp.In(loc).Format(time.RFC3339),
		})
		log.Printf("Message: %+v", m)
	}
	log.Printf("Fetched %d messages for roomId: %s", len(messages), roomId)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(messages)
}
