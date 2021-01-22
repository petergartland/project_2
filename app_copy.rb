require 'sinatra'
require 'digest'
require 'json'
require 'google/cloud/storage'

require 'google/cloud/storage'
storage = Google::Cloud::Storage.new(project_id: 'cs291a')
$bucket = storage.bucket 'cs291project2', skip_lookup: true
puts 'the error should be past here'
puts ''


#file_hexs = Array[]

bodies = {}

get '/' do
  redirect "/files/"
end


get '/files/:digest' do
  file_hexs = getHexs()
  if !isHex(params[:digest])
    status 422
 # puts 'about to get error hexs'
 # file_hexs = getHexs()
 # puts 'here are the error hexs'
 # puts file_hexs
  elsif !file_hexs.include? params[:digest].downcase
    status 404
  else
    content_type bodies[params[:digest].downcase][0]
    puts 'here is the digest: ' + :digest.to_s 
    body bodies[params[:digest].downcase][1]
    status 200
  end
end


def getHexs()
  file_hexs = Array[]
  puts''
  puts '1 is error here?1'
  puts ''
  #$bucket
  all_files = $bucket.files
  puts''
  puts '2 is error here?2'
  puts ''
  all_files.all do |file|
    name = file.name
    if name[2] == '/' and name[5] == '/' and isHexLower(name[0,2]+name[3,2]+name[6,name.length])
      file_hexs.append(name[0,2]+name[3,2]+name[6,name.length])
    end
  end
  puts 'here are the hexs:'
  puts file_hexs
  return file_hexs
end


get '/test/' do
  puts 'here1'
  all_files = $bucket.files
  all_files.all do |file|
    puts 'file path:'
    puts file.name
    name = file.name
    if name[2] == '/' and name[5] == '/' and isHexLower(name[0,2]+name[3,2]+name[6,name.length])
      puts 'is hex' 
      puts ''
      puts 'file content:'
      download = file.download
      download.rewind
      puts download.read()
      end
  end
  puts 'here2'
end


post '/test/upload/' do
  tempfile = params[:file][:tempfile]
  tmp = ''
  File.open(tempfile.path, 'r') do |file|
    puts 'file opened'
  	text = file.read()
  	tmp = Digest::SHA256.hexdigest text
  	tmp = tmp[0,2] + '/' + tmp[2,2] + '/' + tmp[4, tmp.length]
  end  
  $bucket.create_file tempfile, tmp
  puts 'uploaded:'
  puts tmp
  
end


get '/files/' do
  file_hexs = getHexs()
  ret = file_hexs.sort
  body ret.to_json
  status 200
end


post '/files/' do
  if params[:file]
    text = ''
    x = 2.0
    type = ''
    tempfile = '/a/'
    begin
  	  filename = params[:file][:filename]
  	  tempfile = params[:file][:tempfile]
  	  type = params[:file][:type]
  	  target = "public/files/#{filename}"
  	  File.open(tempfile.path, 'r') do |file|
   	    x = file.size() / 1048576.0
  	    text = file.read()
  	  end
  	rescue
  	  status = 422
  	end
  	if x > 1
  	  status 422
  	else
  	  if text.class != 'a'.class
  	    status 422
  	  else
  	    bod = Digest::SHA256.hexdigest text
  	    file_hexs = getHexs()
  	    if file_hexs.include? bod
  	      status 409 
  	    else
  	      #file_hexs.append(bod)
  	      puts ''
  	      tmp = bod[0,2] + '/' + bod[2,2] + '/' + bod[4, bod.length]
  	      puts 'is this where the error is?'
  	      puts ''
  	      $bucket.create_file tempfile, tmp
          puts 'uploaded:'
          puts tmp
  	      
  	      
  	      bodies[bod] = Array[type ,text] 
  	      bod = {"uploaded" => bod}
	      body bod.to_json
	      status 201
	    end
	  end
  	end
  else
 	status 422
  end
end


post '/' do
  require 'pp'
  PP.pp request
  "POST files\n"
end


delete '/files/:digest' do
  puts '11'
  if !isHex(params[:digest])
    status 422
  else
    puts '22'
    #file_hexs.delete(params[:digest].downcase)
    file_hexs = getHexs()
    puts '33'
    puts file_hexs
    puts '44'
    if !file_hexs.include? params[:digest].downcase
      status 200
    else
      puts '55'
      tmp = params[:digest].downcase
      puts '66'
      tmp = tmp[0,2] + '/' + tmp[2,2] + '/' + tmp[4, tmp.length]
      puts'77'
      file = $bucket.file tmp
      puts '88'
      file.delete
      puts '99'
    end
  end
end


def isHex(hex)
  valid_chars = Array['0','1','2','3','4','5','6','7','8','9','a',    					'b','c','d','e','f','A','B','C','D','E','F']
  if hex.class != 'a'.class
    return false
  elsif hex.length != 64
    return false
  end
  for i in 0..hex.length()-1
    if !valid_chars.include? hex[i]
      return false
    end
  end
  return true
end


def isHexLower(hex)
  valid_chars = Array['0','1','2','3','4','5','6','7','8','9','a',    					'b','c','d','e','f']
  if hex.class != 'a'.class
    return false
  elsif hex.length != 64
    return false
  end
  for i in 0..hex.length()-1
    if !valid_chars.include? hex[i]
      return false
    end
  end
  return true
end
