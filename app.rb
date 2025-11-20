require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'





# Routen /
get('/') do
    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    @todos = db.execute("SELECT * FROM todos WHERE finished = ?", "0")
    @finished_todos = db.execute("SELECT * FROM todos WHERE finished = ?", "1")

    slim(:index)
end


post("/add") do
    name = params[:name]
    description = params[:description]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("INSERT INTO todos (name, description, finished) VALUES (?, ?, ?)", [name, description, "0"])

    redirect("/")
end

post("/todos/:id/delete") do
    id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("DELETE FROM todos WHERE id = ?", id)

    redirect("/")
end

get("/:id/edit") do
    id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    @todos = db.execute("SELECT * FROM todos WHERE id = ?", id).first

    slim(:edit)
end


post("/todos/:id/updates") do
  id = params[:id]
  name = params[:name]
  description = params[:description]

  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET name = ?, description = ? WHERE id = ?", [name, description, id])

  redirect("/")
end


post("/:id/finished") do
    id = params[:id]
    finished = "1"

    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET finished = ? WHERE id = ?", [finished, id])

    redirect("/")
end