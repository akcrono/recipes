require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

def get_recipes
  db_connection do |conn|
    conn.exec("SELECT id, name FROM recipes")
  end
end

def get_recipe recipe_id
  db_connection do |conn|
    conn.exec("SELECT recipes.name, recipes.instructions, recipes.description FROM recipes
                where recipes.id = $1", [recipe_id])
  end
end


def get_ingredients recipe_id
  db_connection do |conn|
    conn.exec("SELECT name FROM ingredients
                where ingredients.recipe_id = $1", [recipe_id])
  end
end

get '/' do
  erb :index
end

get '/recipes' do
  @recipes = get_recipes.to_a


  erb :recipes
end

get '/recipe/:recipe_id' do
  @recipe = get_recipe(params[:recipe_id]).to_a.first
  @ingredients = get_ingredients(params[:recipe_id]).to_a


  erb :recipe
end

