package main

import (
 "net/http"
 "fmt"
 "log"
)

func main() {
  http.HandleFunc("/", Hndlr)
  log.Fatal(http.ListenAndServe(":8080", nil))
}

func Hndlr (w http.ResponseWriter, r *http.Request) {
  switch r.Method {
    case http.MethodGet:
      fmt.Fprint(w, "Hello, World")
    default:
      http.Error(w, fmt.Sprintf("%d - Method Not Allowed", http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
  }
}
