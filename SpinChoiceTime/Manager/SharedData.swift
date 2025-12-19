import Foundation

// Categories
let categories = ["Daily", "Food", "Fun", "Challenges", "Custom"]

// Color Themes
let colorThemes = ["Purple-Blue", "Blue-Yellow", "Yellow-Purple", "Neon Mix", "Custom"]

let templates: [Wheel] = [
    Wheel(id: UUID(), name: "What to eat?", category: "Food", colorTheme: "Blue-Yellow", options: ["Pizza", "Salad", "Burger", "Sushi", "Pasta"]),
    Wheel(id: UUID(), name: "Weekend plans", category: "Fun", colorTheme: "Purple-Blue", options: ["Hiking", "Movie Night", "Beach Day", "Gaming", "Reading"]),
    Wheel(id: UUID(), name: "Workout choice", category: "Daily", colorTheme: "Yellow-Purple", options: ["Run", "Yoga", "Weights", "Cycling", "Swim"]),
    Wheel(id: UUID(), name: "Movie night", category: "Fun", colorTheme: "Neon Mix", options: ["Action", "Comedy", "Drama", "Horror", "Sci-Fi"])
]
