require "yaml"

class Game
	@word
	@guesses_left
	@guessed_so_far

	def initialize
		
	end

	def menu
		option = nil
		while !option || option != "n" && option != "o" && option != "q"
			puts "n: new game. o: open the last saved game. q: quit"
			option = gets.chomp[0].downcase
		end

		if option == "n"
			start
		elsif option == "o"
			save_state = YAML.load_file("saved_game.yml")
			save_state.play 

		elsif option == "q"
			exit!
		end
	end

	def load_dictionary
		file = File.open("5desk.txt", "r")
		dictionary = []
		file.each_line do |line|
			line = line.strip #strips leading and trailing whitespace
			if line.length < 12 and line.length > 5
				dictionary << line
			end
		end
		return dictionary
	end

	def guess
		puts @guessed_so_far
		print "\nWrong letters so far: "
		@wrong_letters_guessed.each do |wrong_letter|
			print "#{wrong_letter} "
		end
		input = nil

		while !input
			print "\n\nTo save game, enter save. Guess a letter: "
			input = gets.chomp.downcase			
		end

		if input == "save"
			save_file = File.open("saved_game.yml", "w")
			save_file.write(self.to_yaml)
			save_file.close
			puts "\nGame saved!"
		else
			current_guess = input[0]
			grade_guess(current_guess)
		end
	end

	def grade_guess(guess)
		
		if @word.include? guess
			indices = []
			@word.each_char.with_index do |char,index|
				if char == guess 
					indices << index
				end
			end

			indices.each do |i|
				@guessed_so_far[i*2] = guess
			end
			if !@guessed_so_far.include? "_"
				puts "\n\t#{@guessed_so_far}\n\nYOU WON!"
				@game_over = true

			else
				puts "\nThat's a bingo! #{@guesses_left} wrong guesses still left.\n\n"
			end
		else
			@guesses_left -= 1
			@wrong_letters_guessed << guess if !@wrong_letters_guessed.include? guess
			puts "No dice. #{@guesses_left} wrong guesses left!\n\n"
			if @guesses_left == 0
				puts "You lost. Game over. The word was #{@word}."
				@game_over = true
			end
		end
		puts "---------------------------------------------------------------------"
	end

	def start()
		@guesses_left = 6
		@guessed_so_far = ""
		@game_over = false
		@wrong_letters_guessed = []

		dictionary = load_dictionary
		@word = dictionary[rand(dictionary.size)]
		puts @word
		print "\t"
		@word.length.times do 
			@guessed_so_far << "_ "
		end
		play
	end

	def play
		while !@game_over
			guess
		end 
		menu
	end

	def to_s
		"#{@word}, #{@guesses_left}, #{@guessed_so_far}, #{@wrong_letters_guessed}"
	end

end

g = Game.new

g.menu