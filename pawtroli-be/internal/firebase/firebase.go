package firebase

import (
	"context"
	"log"

	firebase "firebase.google.com/go"
	"google.golang.org/api/option"
)

var App *firebase.App

func InitFirebase() {
	log.Println("Initializing Firebase...")
	opt := option.WithCredentialsFile("configs/firebase_config.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	log.Println("Firebase initialized successfully.")
	if err != nil {
		log.Fatalf("error initializing firebase: %v\n", err)
	}
	App = app
}
