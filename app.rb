require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'


# Routen /
get('/') do
    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    @todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE finished = 0")
    @finished_todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE finished = 1")
    @categories = db.execute("SELECT * FROM categories")

    slim(:index)
end


post("/todos/add") do
    name = params[:name]
    description = params[:description]
    category = params[:category]

    db = SQLite3::Database.new("db/todos.db")
    category_id = db.execute("SELECT id FROM categories WHERE category = ?", category)
    db.execute("INSERT INTO todos (name, description, finished, category) VALUES (?, ?, ?, ?)", [name, description, "0", category_id])

    redirect("/")
end


post("/categories/add") do
    category = params[:category]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("INSERT INTO categories (category) VALUES (?)", category)

    redirect("/")
end


post("/categories/delete") do
    category = params[:category]

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true

    todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id")
    in_use = false
    todos.each do |todo|
        if todo["category"] == category
            in_use = true
            break
        end
    end

    if in_use == false
        db.execute("DELETE FROM categories WHERE category = ?", category)
    else
        p "Unable to delete category #{category} since it is currently in use."
    end

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
    @categories = db.execute("SELECT * FROM categories")    

    slim(:edit)
end


post("/todos/:id/updates") do
  id = params[:id]
  name = params[:name]
  description = params[:description]
  category = params[:category]

  db = SQLite3::Database.new("db/todos.db")
  category_id = db.execute("SELECT id FROM categories WHERE category = ?", category)
  db.execute("UPDATE todos SET name = ?, description = ?, category = ? WHERE id = ?", [name, description, category_id, id])

  redirect("/")
end


post("/:id/finished") do
    id = params[:id]
    finished = "1"

    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET finished = ? WHERE id = ?", [finished, id])

    redirect("/")
end