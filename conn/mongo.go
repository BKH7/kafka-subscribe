package conn

import (
	"context"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// MongoConn initial
func MongoConn() (*mongo.Client, *mongo.Database) {
	clientOptions := options.Client().ApplyURI("mongodb://mongo:27017")
	client, err := mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		panic("Unable to connect mongo: " + err.Error())
	}

	err = client.Ping(context.TODO(), nil)
	if err != nil {
		panic("Unable to connect mongo: " + err.Error())
	}

	db := client.Database("simple")
	return client, db
}
