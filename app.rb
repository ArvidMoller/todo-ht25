require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'
require 'bcrypt'
enable :sessions


get('/') do
    slim(:login)
end
 

get('/todos') do
    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true

    user = session[:user]

    @todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE finished = 0 AND user = ?", user["id"])
    @finished_todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE finished = 1 AND user = ?", user["id"])
    @categories = db.execute("SELECT categories.id, categories.category FROM categories_relative INNER JOIN categories ON categories_relative.category_id = categories.id WHERE user_id = ?", user["id"])

    slim(:index)
end


post("/login") do
    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true

    session.delete(:user_message)
    session.delete(:login_message)

    username = params[:username]
    password = params[:password]

    if username != "" && password != ""
        user = db.execute("SELECT * FROM users WHERE username = ?", [username]).first
        if user != nil && BCrypt::Password.new(user["password"]) == password
            session[:user] = user
            redirect("/todos")
        else
            session[:login_message] = "Incorrect username or password"
            redirect("/")
        end
    else
        session[:login_message] = "Incorrect username or password"
        redirect("/")
    end
end


post("/logout") do 
    session.clear

    redirect("/")
end


post("/user/add") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    # inte samma username

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true

    usernames = db.execute("SELECT username FROM users")
    username_list = []

    usernames.each do |name|
        username_list << name["username"]
    end

    if password == password_confirm && username != "" && password != "" && !username_list.include?(username)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new("db/todos.db")
        db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, password_digest])
        session[:user_message] = "User created!"
    else
        session[:user_message] = "Incorrect password or username already exists"
    end

    session.delete(:login_message)

    redirect("/")
end


post("/user/:id/delete") do 
    user_id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("DELETE FROM todos WHERE user = ?", user_id)
    db.execute("DELETE FROM users WHERE id = ?", user_id)

    redirect("/")
end


post("/todos/add") do
    name = params[:name]
    description = params[:description]
    category_id = params[:category]

    if category_id != nil
        db = SQLite3::Database.new("db/todos.db")
        db.execute("INSERT INTO todos (name, description, finished, category, user) VALUES (?, ?, ?, ?, ?)", [name, description, "0", category_id, session[:user]["id"]])
    end

    redirect("/todos")
end


post("/categories/add") do
    category = params[:category]
    user = session[:user]

    if category != nil
        db = SQLite3::Database.new("db/todos.db")
        db.execute("INSERT INTO categories (category) VALUES (?)", category)

        new_category_id = db.execute("SELECT id FROM categories").last
        db.execute("INSERT INTO categories_relative (user_id, category_id) VALUES (?, ?)", [user["id"], new_category_id])
    end

    redirect("/todos")
end


post("/categories/delete") do
    category_id = params[:category]

    if category_id != nil

        db = SQLite3::Database.new("db/todos.db")
        db.results_as_hash = true

        todos = db.execute("SELECT * FROM todos")
        in_use = false
        todos.each do |todo|
            if todo["category"] == category_id
                in_use = true
                break
            end
        end

        if in_use == false
            db.execute("DELETE FROM categories WHERE id = ?", category_id)
            db.execute("DELETE FROM categories_relative WHERE category_id = ?", category_id)
        else
            p "Unable to delete category category since it is currently in use."
        end
    else
        p "Unable to remove nil category"
    end

    redirect("/todos")
end


post("/todos/:id/delete") do
    id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("DELETE FROM todos WHERE id = ?", id)

    redirect("/todos")
end


get("/:id/edit") do
    id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    @todo = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE todos.id = ?", id).first
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

  redirect("/todos")
end


post("/:id/finished") do
    id = params[:id]
    finished = "1"

    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET finished = ? WHERE id = ?", [finished, id])

    redirect("/todos")
end

post("/:id/unfinished") do
    id = params[:id]
    finished = "0"

    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET finished = ? WHERE id = ?", [finished, id])

    redirect("/todos")
end