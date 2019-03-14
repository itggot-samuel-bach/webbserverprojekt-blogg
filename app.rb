require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require 'securerandom'
enable :sessions

get('/') do
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    
    result = db.execute('SELECT * FROM posts')
    slim(:index, locals:{posts: result, session: session})
end

get('/denied') do
    slim(:denied)
end

get('/accepted') do
    slim(:accepted, locals:{session: session})
end

post('/login') do
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    
    result = db.execute("SELECT id, password FROM users WHERE username=?", [params["username"]])
    if result.length == 0
        redirect('/denied')
    end  
    if BCrypt::Password.new(result[0]["password"]) == params["password"]
        session["user"] = result[0]['id']
        redirect('/accepted')
    else
        redirect('/denied')
    end
end 

post('/create') do
    #Ansluta till db
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    hashed_password = BCrypt::Password.create(params["passwordC"])
    db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [params["usernameC"], hashed_password])

    redirect('/')
end

get('/profile/:id') do
    if session["user"] == params[:id].to_i
        slim(:user)
    else
        redirect('/denied')
    end
end

post('/logout') do
    session.clear
    redirect('/')
end

post('/post') do
    text = params["content"]
    db = SQLite3::Database.new('db/database.db')

    username = db.execute("SELECT username FROM users WHERE id=?", [session["user"]])

    new_file_name = SecureRandom.uuid
    temp_file = params["image"]["tempfile"]
    path = File.path(temp_file)
    
    new_file = FileUtils.copy(path, "./public/img/#{new_file_name}")

    db.execute('INSERT INTO posts (content, picture, userId) VALUES (?, ?, ?)', [text, new_file_name, username])

    redirect('/')

end

post('/delete') do
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true

    
end