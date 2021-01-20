package main

import (
	"context"
	"encoding/json"

	"github.com/BKH7/kafka-simple/realtime/conn"
	"github.com/confluentinc/confluent-kafka-go/kafka"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

func init() {
	viper.SetConfigFile(`config.json`)
	err := viper.ReadInConfig()
	if err != nil {
		panic(err)
	}
}

type msgStruct struct {
	ID        int    `json:"Msg_id"`
	Sender    string `json:"Sender"`
	Msg       string `json:"Msg"`
	CreatedAt int    `json:"createdAt"`
}

func createLog(msg *msgStruct) {
	client, db := conn.MongoConn()
	db.Collection("logs").InsertOne(context.TODO(), msg)
	defer client.Disconnect(context.TODO())
}

func main() {

	c, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers":    viper.GetString("kafka.server"),
		"group.id":             viper.GetString("kafka.consumer.topic"),
		"max.poll.interval.ms": 300000,
		"session.timeout.ms":   10000,
	})
	if err != nil {
		panic(err)
	}

	c.SubscribeTopics([]string{viper.GetString("kafka.consumer.topic")}, nil)
	var m msgStruct
	for {
		msg, err := c.ReadMessage(-1)
		err = json.Unmarshal(msg.Value, &m)
		m.CreatedAt = int(msg.Timestamp.Unix())
		if err == nil {
			logrus.Infof("# %d, %s:%s, %v\n", m.ID, m.Sender, m.Msg, msg.Timestamp.Format("2006-01-02T15:04:05Z07:00"))
			createLog(&m)
		} else {
			// The client will automatically try to recover from all errors.
			logrus.Infof("Consumer error: %v (%v)\n", err, msg)
		}
	}

}
