package main

import (
	"fmt"

	_ "k8s.io/client-go/kubernetes"
)

var nonce = "Friday"

func main() {
	fmt.Printf("Yay! TGI%s!\n", nonce)
}
