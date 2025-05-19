package models

import "time"

type User struct {
	ID        string    `firestore:"-"`         // use for document ID
	Name      string    `firestore:"name"`
	Email     string    `firestore:"email"`
	Phone     string    `firestore:"phone"`
	CreatedAt time.Time `firestore:"createdAt"`
}

type Pet struct {
	ID        string    `firestore:"-"`         // use for document ID
	Name      string    `firestore:"name"`
	Type      string    `firestore:"type"`
	OwnerID   string    `firestore:"ownerId"`
	ImageURL  string    `firestore:"imageUrl"`
	CreatedAt time.Time `firestore:"createdAt"`
}

type PetUpdate struct {
	ID        string    `firestore:"-"`         // use for document ID
	Caption   string    `firestore:"caption"`
	ImageURL  string    `firestore:"imageUrl"`
	Timestamp time.Time `firestore:"timestamp"`
	Shared    bool      `firestore:"shared"`
	PostedBy  string    `firestore:"postedBy"`
}
