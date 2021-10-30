package main

import "fmt"

func main() {
    findDividedBy3(100)
}

func findDividedBy3(n int) {
    for i := 1; i <= n; i++ {
        if i % 3 == 0 {
            fmt.Printf("%d ", i)
        }
    }
}