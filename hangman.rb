class Hangman

  attr_accessor :guessing_player, :checking_player, :display

  def initialize(guessing_player, checking_player)
    self.guessing_player = guessing_player
    self.checking_player = checking_player
  end

  def play
    puts "Welcome to Hangman"
    checking_player.pick_secret_word
    self.display = '_' * checking_player.receive_secret_length
    turns_left = 10

    until game_won? || turns_left == 0
      puts "#{turns_left} turns remaining. \n#{display}\n\n"
      do_guess = guessing_player.guess
      indices = checking_player.check_guess(do_guess)
      indices.each { |id| display[id] = checking_player.secret_word[id] } unless indices == [-1]
      guessing_player.handle_guess_response(display)
      turns_left -= 1
    end

    puts "#{game_won? ? "Guesser" : "Checker"} wins! The word was #{checking_player.secret_word}."

  end

  def game_won?
    !display.include?('_')
  end


end

class HumanPlayer

  attr_accessor :dictionary, :secret_word, :guessed_letters

  def initialize(dictionary)
    self.dictionary = dictionary
    self.guessed_letters = []
  end

  def pick_secret_word
    begin
      print "Input a word length for the secret word: "
      length = Integer(gets.chomp)
    rescue ArgumentError
      puts "Please enter a valid integer!"
      retry
    end
    self.secret_word = dictionary.select{|word| word.length == length}.sample
    puts "Your word is #{secret_word}."
  end

  def receive_secret_length
    secret_word.length
  end

  def guess
    print "Please guess a letter: "
    letter = gets.chomp

    while guessed_letters.include?(letter)
      print "You've already guessed that, try again: "
      letter = gets.chomp
    end

    guessed_letters << letter
    letter
  end

  def check_guess(letter)
    puts "Computer guesses #{letter}."
    print "Input the indices where the letter occurs (-1 if it doesn't occur): "
    gets.chomp.split(",").map {|id| id.to_i}
  end

  def handle_guess_response(display)
  end

end

class ComputerPlayer

  attr_accessor :dictionary, :secret_word, :guessed_letters, :my_guess

  def initialize(dictionary)
    self.dictionary = dictionary
    self.guessed_letters = []
  end

  def pick_secret_word
    self.secret_word = dictionary.sample
  end

  def receive_secret_length
    secret_word.length
  end

  def guess
    self.my_guess = smart_guess
    my_guess
  end

  def check_guess(letter)
    indices = []
    secret_word.split("").each_with_index { |char, i| indices << i if letter == char}
    indices
  end

  def handle_guess_response(display)
    if display.split("").include?(my_guess)
      dictionary.select! { |word| is_valid_word?(display, word) }
    else
      dictionary.select! {|word| !word.include?(my_guess)}
    end
  end


  private

    def smart_guess
      letter_bank = dictionary.join("")
      counts_hash = {}
      ('a'..'z').each do |letter|
        counts_hash[letter] = letter_bank.count(letter)
      end
      choice = counts_hash.keys.max_by { |letter| counts_hash[letter] }
      while guessed_letters.include?(choice)
        counts_hash[choice] = -1
        choice = counts_hash.keys.max_by { |letter| counts_hash[letter] }
      end
      guessed_letters << choice
      choice
    end

    def dumb_guess
      letter = ('a'..'z').to_a.sample
      while guessed_letters.include?(letter)
        letter = ('a'..'z').to_a.sample
      end
      guessed_letters << letter
      letter
    end

    def is_valid_word?(display, bank_word)
      display.split("").each_with_index do |letter, id|
        return false if letter != '_' && bank_word[id] != letter
      end
      true
    end

end



word_list = File.readlines("dictionary.txt").map{ |line| line.chomp }
human = HumanPlayer.new(word_list)
computer = ComputerPlayer.new(word_list)
test = Hangman.new(computer, human)
test.play
