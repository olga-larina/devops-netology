package main

import "fmt"

func main() {
    fmt.Print("Enter value in meters: ")

    var input float64
    fmt.Scanf("%f", &input)

    fmt.Printf("Value in feet = %f \n", fromMetersToFeet(input))
}

func fromMetersToFeet(meters float64) (float64){
    return meters / 0.3048
}