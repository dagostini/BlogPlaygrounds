//: Playground - noun: a place where people can play

import UIKit


// MARK: - Structures Example
struct Book {
    var title: String
    var author: String
}

let originalBook = Book(title: "How to survive on less than 2000€ in Dublin", author: "Anonymous")
var copiedBook = originalBook
copiedBook.author = "Some guy"

print(originalBook)


// MARK: - Classes Example
class Planet: CustomDebugStringConvertible {
    var name: String
    var galaxy: String
    
    init(name: String, galaxy: String) {
        self.name = name
        self.galaxy = galaxy
    }
    
    var debugDescription: String {
        return "\(name):\(galaxy)"
    }
}

let earth = Planet(name: "earth", galaxy: "current one")

let backupEarth = earth
backupEarth.name = "backup earth"

print(earth)


// MARK: - Arrays Example
var planets = [Planet(name: "abc123", galaxy: "andromeda"), Planet(name: "xyz987", galaxy: "milkyway")]

var newPlanets = planets

newPlanets.append(Planet(name: "earth", galaxy: "this one"))

print("Original: ", planets)
print("Copy: ", newPlanets)
