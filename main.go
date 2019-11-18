package main

import (
	"context"
	"database/sql"
	"net/http"
	"os"
	"time"

	"github.com/etherlabsio/healthcheck"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

func main() {

	username := os.Getenv("MYSQL_USERNAME")
	password := os.Getenv("MYSQL_PASSWORD")
	host := os.Getenv("MYSQL_HOST")
	dbname := os.Getenv("MYSQL_DATABASE")

	connectionString := username + ":" + password + "@tcp(" + host + ":3306)/" + dbname

	// For brevity, error check is being omitted here.
	db, _ := sql.Open("mysql", connectionString)
	defer db.Close()

	r := mux.NewRouter()
	r.Handle("/healthcheck", healthcheck.Handler(

		// WithTimeout allows you to set a max overall timeout.
		healthcheck.WithTimeout(5*time.Second),

		healthcheck.WithChecker(
			"database", healthcheck.CheckerFunc(
				func(ctx context.Context) error {
					return db.PingContext(ctx)
				},
			),
		),

	))

	http.ListenAndServe(":8080", r)
}