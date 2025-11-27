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
end

def create_tables(db)
  db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              finished boolean, 
              category INTEGER)')

  db.execute('CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT)')
end

def populate_tables(db)
  db.execute('INSERT INTO todos (name, description, finished, category) VALUES ("Köp mjölk", "3 liter mellanmjölk, eko", false, 1)')
  db.execute('INSERT INTO todos (name, description, finished, category) VALUES ("Möte", "Möte med chefen kl. 12", false, 2)')
  db.execute('INSERT INTO todos (name, description, finished, category) VALUES ("Göra läxor", "Göra engelska läxor", false, 3)')

  db.execute('INSERT INTO categories (category) VALUES ("Private")')
  db.execute('INSERT INTO categories (category) VALUES ("Work")')
  db.execute('INSERT INTO categories (category) VALUES ("School")')
end

seed!(db)