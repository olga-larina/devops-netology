package main

import (
    "testing"
    "errors"
)

func Test1Task2(t *testing.T) {
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
    min, err := findMinElement(x)
    if min != 9 {
        t.Error("Expected 9, got ", min)
    }
    if (err != nil) {
        t.Error("Expected success, got ", err)
    }
}

func Test2Task2(t *testing.T) {
    x := []int{}
    min, err := findMinElement(x)
    if min != -1 {
        t.Error("Expected -1, got ", min)
    }
    if (err == nil) {
        t.Error("Expected error, got nil")
    }
    if errors.Is(err, errors.New("No elements in array")) {
        t.Error("Expected No elements in array, got ", err)
    }
}