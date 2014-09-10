class Hangman
  
  attr_accessor :wordmask, :secret_word
  
  def initialize
    @wordmask = []
  end
  
  def play guesser, game_maker
    word_length = game_maker.pick_secret_word
    @wordmask = Array.new(word_length, '_')
    until game_maker.game_over? @wordmask
      puts @wordmask.join
      guesser.priority_list(word_length)
      letter = guesser.guess
      letter_index = game_maker.check_guess(letter, @wordmask)
      guesser.filter_dictionary(letter_index,letter)   
    end
    puts @wordmask.join
    puts "You win!!"
  end

end


class HumanPlayer
  
  attr_reader :game_over
  
  def initialize 
    @game_over = false
    @guessed_letters = []
  end
  
  def guess
    puts "Enter in a guess"
    letter = gets.chomp
    @guessed_letters << letter unless @guessed_letters.include?(letter)
    p @guessed_letters
    letter
  end
  
  def filter_dictionary a,b
  end
  
  def priority_list
  end
  
  def pick_secret_word
    puts "What is your secret word"
    @secret_word = gets.chomp.split('')
    @secret_word.length
  end  
   
  def check_guess (letter, wordmask)
    puts "What position is the letter #{letter.upcase}? (enter if none)"
    letter_index = gets.chomp.split.map{ |pos| pos.to_i } 
    letter_index.each do |index|
      wordmask[index] = letter 
    end
    letter_index
  end
  
  def game_over? wordmask
    @secret_word == wordmask  
  end
  
end


class ComputerPlayer
  attr_reader :game_over
  
  def initialize
    @dictionary = File.readlines("dictionary.txt").map{|word|word.chomp}
    @guessed_letters = []
    @game_over = false
    @priority_list=Hash.new(0)
  end
  
  def pick_secret_word
    @secret_word = @dictionary.sample.split('')
    @secret_word.length 
  end
  
  def guess
    letter = @priority_list.max_by{|key, value| value }[0]    
    @guessed_letters << letter
    
    p @guessed_letters
    letter
  end
  
  def priority_list length
    @priority_list = Hash.new(0)
    @dictionary = @dictionary.select{|word| word.length == length}
    @dictionary.each do |word|
      word.split('').each do |letter| 
        @priority_list[letter] = @priority_list[letter] + 1
      end
    end
    @guessed_letters.each do |char|
      @priority_list.delete(char) 
    end
  end
  
  def check_guess letter, wordmask
    if @secret_word.include?(letter)
      @secret_word.each_with_index do |char, index|
        if char == letter
          wordmask[index] = letter 
        else 
          puts "Letter not included"
        end
      end
      []
    end
  end
  
  def filter_dictionary letter_index, letter
    unless letter_index.empty?
      @dictionary = @dictionary.select do |word|
        word_index=[]
        word.split('').each_with_index do |char,index|
          if char==letter
            word_index<<index
          end
        end
        word_index==letter_index
      end
    end
    p @dictionary
  end
    
  def game_over? wordmask
    @secret_word == wordmask
  end  
end

Hangman.new.play(ComputerPlayer.new,HumanPlayer.new)
