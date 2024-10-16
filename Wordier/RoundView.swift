//
//  RoundView.swift
//  Wordier
//
//  Created by Grace Potter on 10/14/24.
//

import SwiftUI

struct RoundView: View {
    @State private var textBoxContent: String = ""    // Holds the text to be displayed in the text box
    @State private var submittedWord: String? = nil   // Holds the final submitted word
    @State private var shuffledLetters: [String] = ["S", "A", "M", "P", "L", "E"].shuffled() // Randomized letters
    @State private var submittedWords: [String] = []  // Holds the list of all submitted words
    @State private var errorMessage: String? = nil    // Error message for invalid word submission
    @State private var usedLetters: Set<String> = []  // Track used letters for the current word
    
    @State private var validWords: Set<String> = []   // Holds the set of valid words loaded from the word list
    @State private var possibleWordPlaceholders: [String] = []   // Holds placeholders or words as they are found

    var body: some View {
        VStack {
            // Text box displaying the selected letters
            HStack {
                TextField("Selected letters will appear here", text: $textBoxContent)
                    .font(.title)
                    .padding()
                    .frame(height: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true) // Make it read-only for user input
                
                // Delete button to remove the last letter from the text box
                Button(action: {
                    if let lastLetter = textBoxContent.last.map(String.init) {
                        // Remove the last letter from the text box
                        textBoxContent.removeLast()
                        // Re-enable the button for the removed letter
                        usedLetters.remove(lastLetter)
                    }
                }) {
                    Text("Delete")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 20)

            // Horizontal alignment for letter squares
            HStack {
                ForEach(shuffledLetters, id: \.self) { letter in
                    // Each square is a button that adds the letter to the text box
                    Button(action: {
                        textBoxContent += letter
                        usedLetters.insert(letter) // Mark the letter as used
                    }) {
                        Text(letter)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(usedLetters.contains(letter) ? Color.gray : Color.blue) // Grey out used letters
                            .cornerRadius(10)
                            .padding(5)
                    }
                    .disabled(usedLetters.contains(letter)) // Disable button if the letter has been used
                }
            }
            .padding(.bottom, 20)
            
            // Enter button
            Button(action: {
                if !textBoxContent.isEmpty {
                    // Check if the word is a valid English word
                    if isValidEnglishWord(word: textBoxContent) {
                        // Check for duplicates
                        if !submittedWords.contains(textBoxContent) {
                            submittedWords.append(textBoxContent)
                            // Sort first by word length, then alphabetically
                            submittedWords.sort {
                                if $0.count == $1.count {
                                    return $0 < $1 // Sort alphabetically if lengths are the same
                                }
                                return $0.count < $1.count // Sort by word length
                            }
                            submittedWord = textBoxContent
                            errorMessage = nil // Clear any previous error
                            textBoxContent = "" // Clear the text box after submission
                            usedLetters.removeAll() // Reset used letters for the next word
                        } else {
                            errorMessage = "\(textBoxContent) has already been submitted."
                        }
                    } else {
                        errorMessage = "\(textBoxContent) is not a valid English word or is too short."
                    }
                }
            }) {
                Text("Enter")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
            }
            
            // Display the last submitted word
            if let word = submittedWord {
                Text("You made the word: \(word)")
                    .font(.title2)
                    .padding(.top, 20)
            }
            
            // Display error message if invalid word is submitted
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            // Section for possible words and their placeholders
            if !possibleWordPlaceholders.isEmpty {
                Text("Possible Words:")
                    .font(.headline)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack {
                        ForEach(possibleWordPlaceholders, id: \.self) { word in
                            Text(word)
                                .padding(5)
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .frame(maxHeight: 200)
                .border(Color.gray, width: 1)
            }

            // Shuffle button to randomize the letters again
            Button(action: {
                shuffledLetters = shuffledLetters.shuffled() // Reshuffle the letters
                usedLetters.removeAll() // Clear used letters when shuffling
                generatePossibleWords() // Regenerate the list of possible words
            }) {
                Text("Shuffle Letters")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding()
            }

            Spacer() // Push content to the top
        }
        .padding()
        .onAppear {
            loadWordList()       // Load the word list when the view appears
            generatePossibleWords() // Generate possible words when the view appears
        }
    }
    
    // Function to load the word list from a file
    func loadWordList() {
        if let path = Bundle.main.path(forResource: "words", ofType: "txt") {
            do {
                let wordListContent = try String(contentsOfFile: path)
                let wordArray = wordListContent.components(separatedBy: .newlines)
                validWords = Set(wordArray.filter { !$0.isEmpty }) // Load words into a set for quick lookup
            } catch {
                print("Failed to load word list: \(error)")
            }
        }
    }

    // Function to generate all possible valid words with the shuffled letters
    func generatePossibleWords() {
        possibleWordPlaceholders = [] // Clear the current list
        let letterCombinations = generateCombinations(from: shuffledLetters)
        
        // Check which combinations are valid words
        for combination in letterCombinations {
            if isValidEnglishWord(word: combination) {
                possibleWordPlaceholders.append(combination) // Add valid word to the list
            } else {
                // Add placeholders if it's not a valid word
                possibleWordPlaceholders.append(String(repeating: "_ ", count: combination.count).trimmingCharacters(in: .whitespaces))
            }
        }
        
        // Sort possible words by length, then alphabetically
        possibleWordPlaceholders.sort {
            if $0.count == $1.count {
                return $0 < $1
            }
            return $0.count < $1.count
        }
    }
    
    // Function to generate all possible combinations of the shuffled letters
    func generateCombinations(from letters: [String]) -> [String] {
        var combinations: [String] = []
        
        // Generate all possible combinations of length 3 or greater
        for length in 3...letters.count {
            combinations += permutations(of: letters, length: length)
        }
        
        return combinations
    }
    
    // Function to generate all permutations of the given letters for a specific length
    func permutations(of letters: [String], length: Int) -> [String] {
        if length == 1 {
            return letters
        }
        
        var result: [String] = []
        for (index, letter) in letters.enumerated() {
            var remainingLetters = letters
            remainingLetters.remove(at: index)
            let subPermutations = permutations(of: remainingLetters, length: length - 1)
            result += subPermutations.map { letter + $0 }
        }
        return result
    }

    // Function to check if the word is in the valid word list
    func isValidEnglishWord(word: String) -> Bool {
        return validWords.contains(word.lowercased()) && word.count >= 3
    }
}

struct RoundView_Previews: PreviewProvider {
    static var previews: some View {
        RoundView()
    }
}


