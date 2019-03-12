require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions

get('/') do
    slim(:index, locals:{session: session})
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
    slim(:user)
end

post('/logout') do
    session.destroy
    slim(:index)
end