Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == "si@yelo"
end

