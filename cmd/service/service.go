package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
	})
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Ok")
	})
	log.Fatal(http.ListenAndServe(":8080", nil))

}
