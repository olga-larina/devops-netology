package main

import (
    "fmt"
)

func main() {
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
//     x := []int{}

    min, err := findMinElement(x)
    if err != nil {
        fmt.Printf("Error = %s \n", err)
    } else {
        fmt.Printf("Min element = %d \n", min)
    }
}

func findMinElement(x []int) (int, error) {
    if len(x) == 0 {
        return -1, fmt.Errorf("No elements in array")
    }
    result := x[0]
    for i := 1; i < len(x); i++ {
        if result > x[i] {
            result = x[i]
        }
    }
    return result, nil
}