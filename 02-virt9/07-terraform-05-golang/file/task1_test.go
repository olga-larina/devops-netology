package main

import "testing"

func Test1Task1(t *testing.T) {
    var v float64
    v = fromMetersToFeet(3.0480)
    if v != 10 {
        t.Error("Expected 10, got ", v)
    }
}

func Test2Task1(t *testing.T) {
    var v float64
    v = fromMetersToFeet(0)
    if v != 0 {
        t.Error("Expected 0, got ", v)
    }
}