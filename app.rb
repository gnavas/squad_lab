require 'sinatra'
require 'pry'
require 'better_errors'
require 'pg'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'squads_lab')

before do
  @conn = settings.conn
end

# Root
get '/' do
redirect '/squads'
end

#Index List Squads
get'/squads' do
  squads = []
  @conn.exec("SELECT * FROM squads") do |result|
  result.each do |squad|
    squads << squad  
  end
  end
  @squads = squads  
  erb :index
end

#New Squad - Get form to add new Squad
get '/squads/new' do
  erb :new
end

#Show Squad - More Info on Squad
get '/squads/:squad_id' do
  id = params[:squad_id].to_i
  tsquad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1",[id])
  @tsquad = tsquad[0]
  erb :show
end

#Update - Get form to Edit a Squad
get '/squads/:squad_id/edit' do
id = params[:squad_id].to_i
tsquad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1",[id])
@tsquad = tsquad[0]
erb :show
end

#List Squad Students
get '/squads/:squad_id/students' do
  students=[]
  id = params[:squad_id].to_i
 @conn.exec("SELECT * FROM students WHERE squad_id = $1",[id]) do |result|
  result.each do |student|
    students << student
  end  
  end

  @students = students
  erb :show_students

end

#New Student - Get form to Add Student to Squad
get '/squads/:squad_id/students/new' do
  erb :new_student
end

#Show Student - Show More Info on student from squad
get '/squads/:squad_id/students/:student_id' do
  id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  tstudent = @conn.exec("SELECT * FROM students WHERE squad_id = $1 AND student_id = $2",[id,student_id])
  @tstudent = tstudent[0]
  erb :show_student
end

#Update - Get Form to Update Student Info
get '/squads/:squad_id/students/:student_id/edit' do
  end











