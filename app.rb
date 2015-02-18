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
  # squads = []
 @squads =  @conn.exec("SELECT * FROM squads ORDER BY squad_name ASC") 
  # do |result|
  #   result.each do |squad|
  #     squads << squad  
  #   end
  # end
  # @squads = squads  
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
  erb :edit
end

#List Squad Students
get '/squads/:squad_id/students' do
  begin
    students=[]
    id = params[:squad_id].to_i
    @conn.exec("SELECT * FROM students WHERE squad_id = $1 ORDER BY name ASC",[id]) do |result|
      result.each do |student|
        students << student
      end  
    end

    team_name = @conn.exec("SELECT squad_name FROM squads JOIN students on squads.squad_id = students.squad_id WHERE squads.squad_id=$1",[id])
    @team_name=team_name[0]
    @students = students
    @squadname = @students[0]
    erb :show_students
  rescue IndexError
    redirect "/squads/#{id}/students/student_null/new"
  end
end
#CREATE Student - Get form to Add Student to Squad when Squad is currently empty
get'/squads/:squad_id/students/student_null/new' do
  erb :new_first_student
end

#CREATE Student - Get form to Add Student to Squad
get '/squads/:squad_id/students/new' do
  erb :new_student
end

#Show Student - Show More Info on student from squad
get '/squads/:squad_id/students/:student_id' do
  id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  tstudent = @conn.exec("SELECT * FROM students WHERE squad_id = $1 AND student_id = $2",[id,student_id])
  @tstudent = tstudent[0]
  team_name = @conn.exec("SELECT squad_name FROM squads JOIN students on squads.squad_id = students.squad_id WHERE squads.squad_id=$1",[id])
  @team_name=team_name[0]
  erb :show_student
end

#Update - Get Form to Update Student Info
get '/squads/:squad_id/students/:student_id/edit' do
  id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  tstudent = @conn.exec("SELECT * FROM students WHERE squad_id = $1 AND student_id = $2",[id,student_id])
  @tstudent = tstudent[0]
  erb :edit_students
end

# "REDIRECT BACK" = redirect user back to previous page
get 'squads/3/students' do
  redirect back
end 


  # CREATE = Add a new Team
  post '/squads' do
   new_name = params[:name]
   new_mascot = params[:mascot] 
   @conn.exec("INSERT INTO squads (squad_name ,mascot) VALUES ($1,$2)",[new_name,new_mascot]) 
   redirect'/squads' 
 end

# CREATE = Add a new Student
post '/squads/:squad_id/students' do
  student_squad = params[:squad_id].to_i
  student_name = params[:name]
  student_age = params[:age].to_i
  student_spirit_animal = params[:spirit_animal]
  @conn.exec("INSERT INTO students (squad_id, name, age, spirit_animal) VALUES ($1,$2,$3,$4)",[student_squad,student_name,student_age,student_spirit_animal])
  redirect"/squads/#{params[:squad_id].to_i}/students" 
end

  # Update Team Info
  put '/squads/:squad_id' do 
    updated_squad = params[:squad_name].to_s
    updated_mascot = params[:mascot].to_s
    id = params[:squad_id].to_i
    @conn.exec("UPDATE squads SET (squad_name,mascot) = ($1,$2) WHERE squad_id = $3", [updated_squad,updated_mascot,id])
    redirect'/'
end

  # Update Student Info
  put '/squads/:squad_id/students/:student_id' do 
    updated_name = params[:name].to_s
    updated_age = params[:age].to_i
    updated_spirit_animal = params[:spirit_animal]
    id = params[:squad_id].to_i
    sid = params[:student_id].to_i
    @conn.exec("UPDATE students SET (name,age,spirit_animal) = ($1,$2,$3) WHERE squad_id = $4 AND student_id = $5", [updated_name,updated_age,updated_spirit_animal,id,sid])
    redirect"/squads/#{params[:squad_id]}/students"
  end

  #Destroy Team Info - Can only be deleted if there are no underlying students 
  delete '/squads/:squad_id' do 
    begin 
      id = params[:squad_id].to_i
      @conn.exec("DELETE FROM squads WHERE squad_id = $1", [id])
      redirect'/'
    rescue 
     erb :delete_error
    end
end
# Destroy Student Info
delete '/squads/:squad_id/students/:student_id' do 
  id = params[:squad_id].to_i
  sid = params[:student_id].to_i
  @conn.exec("DELETE FROM students WHERE squad_id = $1 AND student_id = $2", [id,sid])
  redirect"/squads/#{params[:squad_id]}/students"
end
#Destroy all student of SQUAD 
delete '/squads/:squad_id/students' do 
  id = params[:squad_id].to_i
  @conn.exec("DELETE FROM students WHERE squad_id = $1", [id])
  redirect"/squads/#{id}"
end














