package main

import (
        "net/http/httptest"
        "net/http"
        //"strings"
        "testing"
)

func TestHndlr (t *testing.T) {
        tests := []struct {
                method string
                code  int
        }{
          {method: http.MethodGet, code: http.StatusOK},
          {method: http.MethodPut, code: http.StatusMethodNotAllowed},
          {method: http.MethodPost, code: http.StatusMethodNotAllowed},
        }

        for _, test := range tests {
                req := httptest.NewRequest(test.method, "/", nil)

                rr := httptest.NewRecorder()
                Hndlr(rr, req)

                if rr.Code != test.code {
                        t.Errorf("Hndlr(%s) = %d, expected %d. Error message: %s", test.method, rr.Code, test.code, rr.Body.String())
                }
        }
}
