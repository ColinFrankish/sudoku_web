require 'sinatra'
require 'sinatra/partial' 
require 'rack-flash'

require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application.rb'

enable :sessions
set :session_secret, "I'm the secret key to sign the cookie"
use Rack::Flash
set :partial_template_engine, :erb

configure :production do 
  require 'newrelic_rpm'
end


def random_sudoku
  # we're using 9 numbers, 1 to 9, and 72 zeros as an input
  # it's obvious there may be no clashes as all numbers are unique
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  # then we solve this (really hard!) sudoku
  sudoku.solve!
  # and give the output to the view as an array of chars
  sudoku.to_s.chars
end

def puzzle(sudoku)
  new_sudoku = sudoku.dup
  (0..81).to_a.sample(25).each { |i| new_sudoku[i] =" "}
  new_sudoku
end

get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle] 
  erb :index
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) do |memo, i|
  first_box_index = i / 3 * 3
  three_boxes = boxes[first_box_index, 3]
  three_rows_of_three = three_boxes.map do |box| 
  row_number_in_a_box = i % 3
  first_cell_in_the_row_index = row_number_in_a_box * 3    
  box[first_cell_in_the_row_index, 3]
    end
    memo += three_rows_of_three.flatten
  end
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  if @check_solution
    flash[:notice] = "Incorrect values are highlighted in yellow."
  end
  session[:check_solution] = nil
end


def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle] 
end

get '/solution' do 
  @check_solution = true
  @current_solution = session[:solution] #|| session[:puzzle]
  @puzzle = session[:puzzle]
  @solution = session[:solution]
  erb :index
end


post '/' do
  # the cells in HTML are ordered box by box 
  # (first box1, then box2, etc),
  # so the form data (params['cell']) is sent using this order
  # However, our code expects it to be row by row, 
  # so we need to transform it.
  cells = box_order_to_row_order(params["cell"]) # ?????
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end

get '/reset' do
  session[:current_solution] = nil
  redirect to("/")
end



