//
//  RoundView.swift
//  Wordier
//
//  Created by Grace Potter on 10/14/24.
//

import SwiftUI

struct RoundView: View {
    @State private var textBoxContent: String = ""    // Holds the text to be displayed in the text box
    @State private var submittedWord: String? = nil   // Holds the last submitted word
    @State private var shuffledLetters: [String] = []  // Randomized letters
    @State private var submittedWords: [String] = []   // Holds the list of all submitted words
    @State private var errorMessage: String? = nil     // Error message for invalid word submission
    @State private var letterButtonStates: [Bool] = [] // Track the state of each letter button (true = active, false = used)
    @State private var validWords: Set<String> = []    // Holds the set of valid words loaded from the word list
    @State private var possibleWordPlaceholders: [String] = [] // Holds placeholders or words as they are found
    @State private var possibleWords: [String] = [] // Holds words as they are found



    var body: some View {
        VStack {
            
            // Horizontal alignment for letter squares
            HStack {
                ForEach(shuffledLetters.indices, id: \.self) { index in
                    let letter = shuffledLetters[index]
                    // Each square is a button that adds the letter to the text box
                    Button(action: {
                        textBoxContent += letter
                        letterButtonStates[index] = false // Mark the letter at this index as used
                    }) {
                        Text(letter)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(letterButtonStates[index] ? Color.blue : Color.gray) // Gray out only the used letter at this index
                            .cornerRadius(5)
                            .padding(5)
                    }
                    .disabled(!letterButtonStates[index]) // Disable the button if it was already used
                }
                Button(action: {
                                shuffleLetters()
                            }) {
                                Image(systemName: "arrow.2.circlepath")
                                    .font(.title)
                                    .foregroundColor(.black)
                                    .padding()
                            }
            }
            .padding(.bottom, 20)
            
            
            // Text box displaying the selected letters
            HStack {
                TextField("Selected letters will appear here", text: $textBoxContent)
                    .font(.title2)
                    .padding()
                    .frame(height: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true) // Make it read-only for user input
                
                // Delete button to remove the last letter from the text box
                Button(action: {
                    if let lastLetter = textBoxContent.last {
                        textBoxContent.removeLast()
                        // Find the index of the last added letter and reset its button state
                        if let indexToReset = shuffledLetters.firstIndex(of: String(lastLetter)) {
                            letterButtonStates[indexToReset] = true // Reset button state for this letter
                        }
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 5)

            HStack {
                // Shuffle button to randomize the letters again
                Button(action: {
                    selectRandomWord() // Select a new random word
                }) {
                    Text("New Word")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding()
                }
                
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
                                letterButtonStates = Array(repeating: true, count: shuffledLetters.count) // Reset all buttons for the next word
                            } else {
                                errorMessage = "\(textBoxContent) has already been submitted."
                                textBoxContent = "" // Clear the text box after submission
                                letterButtonStates = Array(repeating: true, count: shuffledLetters.count) // Reset all buttons for the next word
                            }
                        } else {
                            errorMessage = "\(textBoxContent) is not a valid English word or is too short."
                            textBoxContent = "" // Clear the text box after submission
                            letterButtonStates = Array(repeating: true, count: shuffledLetters.count) // Reset all buttons for the next word
                        }
                    }
                }) {
                    Text("Enter")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding()
                }
            }
            
            // Display the last submitted word
            if let word = submittedWord {
                Text("Last word submitted: \(word)")
                    .padding(.top, 10)
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
                
                ScrollView{
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
                        ForEach(possibleWordPlaceholders, id: \.self) { word in
                            Text(word)
                        }
                    }
                }
                
                .frame(maxHeight: 650)
                .border(Color.gray, width: 1)
            }

            Spacer() // Push content to the top
        }
        .padding()
        .onAppear {
            loadWordList()       // Load the word list when the view appears
            selectRandomWord()    // Select a random word to generate letters
        }
    }
    
    // Function to shuffle the letters
    func shuffleLetters() {
        shuffledLetters.shuffle()
        letterButtonStates = Array(repeating: true, count: shuffledLetters.count) // Reset button states
        textBoxContent = "" // Clear the text box
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

    // Function to select a random word between 6 and 8 characters
    func selectRandomWord() {
        let validWordsList = validWords.filter { $0.count >= 5 && $0.count <= 7 }
        if let randomWord = validWordsList.randomElement() {
            shuffledLetters = randomWord.map { String($0) } // Create buttons from letters
            shuffledLetters.shuffle() // Shuffle the letters
            textBoxContent = "" // Clear text box for the new word
            letterButtonStates = Array(repeating: true, count: shuffledLetters.count) // Reset button states for the new word
            generatePossibleWords() // Regenerate possible words
        }
    }
    
    // Function to generate all possible valid words with the shuffled letters
    func generatePossibleWords() {
        possibleWordPlaceholders = [] // Clear the current list
        possibleWords = [] // Clear the current list
        
        let letterCombinations = generateCombinations(from: shuffledLetters)
        
        // Check which combinations are valid words
        for combination in letterCombinations {
            if isValidEnglishWord(word: combination) {
                possibleWords.append(combination) // Add valid word to the list
                
            }
        }
        
        // Sort possible words by length, then alphabetically
        possibleWords.sort {
            if $0.count == $1.count {
                return $0 < $1
            }
            return $0.count < $1.count
        }
        
        // Add placeholder
        possibleWordPlaceholders = possibleWords
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
            for permutation in subPermutations {
                result.append(letter + permutation)
            }
        }
        
        return result
    }
    
    // Function to check if the submitted word is part of the English dictionary and meets the length requirement
    func isValidEnglishWord(word: String) -> Bool {
        return validWords.contains(word) && word.count >= 3
    }
}




struct RoundView_Previews: PreviewProvider {
    static var previews: some View {
        RoundView()
    }
}
