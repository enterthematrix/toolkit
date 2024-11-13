#!/bin/bash

# Function to scale up
scale_up() {
    displayplacer "id:310C70C2-EBF0-407F-8962-287ACF1B4BAD res:3200x900"
    echo "Screen scaled up to 3200x900."
}

# Function to scale down
scale_down() {
    displayplacer "id:310C70C2-EBF0-407F-8962-287ACF1B4BAD res:3840x1080"
    echo "Screen scaled down to 3840x1080."
}

case "$1" in
    up)
        scale_up
        ;;
    down)
        scale_down
        ;;
    *)
        echo "Usage: $0 up | down"
        ;;
esac