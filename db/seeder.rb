require 'sqlite3'

db = SQLite3::Database.new("todos.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS todos')
  db.execute('DROP TABLE IF EXISTS categories')
  db.execute('DROP TABLE IF EXISTS users')
  db.execute('DROP TABLE IF EXISTS categories_relative')
end

def create_tables(db)
  db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              finished boolean, 
              category INTEGER, 
              user INTEGER)')

  db.execute('CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT)')

  db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              username TEXT, 
              password TEXT)')

  db.execute('CREATE TABLE categories_relative (
              user_id INTEGER, 
              category_id INTEGER)')
end

def populate_tables(db)
  db.execute('INSERT INTO categories (category) VALUES ("Private")')
  db.execute('INSERT INTO categories (category) VALUES ("Work")')
  db.execute('INSERT INTO categories (category) VALUES ("School")')

  db.execute('INSERT INTO categories_relative (user_id, category_id)  VALUES (1, 1)')
  db.execute('INSERT INTO categories_relative (user_id, category_id)  VALUES (1, 2)')
  db.execute('INSERT INTO categories_relative (user_id, category_id)  VALUES (1, 3)')

end

seed!(db)