require 'sinatra'
require 'digest'
require 'json'


#file_hexs = Array['78edC928b486B2618B6F94774eD1649FB5B2550e59fe825ADf5a02080345fbA5']
file_hexs = Array[]

bodies = {}

get '/' do
  redirect "/files/"
end


get '/files/:digest' do
  if !isHex(params[:digest])
    #puts 'TEST1@@@@@@@@@@@@@@@@@@@@'
    status 422
  else
    status 200
    content_type = 'test?'
    puts 'here is the digest: ' + :digest.to_s 
    body bodies[params[:digest]] #may need to fix the uppercase/lowercase
  end
end

get '/files/' do
  ret = file_hexs.sort
  body ret.to_json
  status 200
end



post '/files/' do
  if params[:file]
    text = ''
    x = 3.0
    begin
  	  filename = params[:file][:filename]
  	  tempfile = params[:file][:tempfile]
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
  	    if file_hexs.include? bod
  	      status 409 #change back to 409
  	    else
  	      file_hexs.append(bod)
  	      bodies[bod] = text
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
#  statusCode: 333
end

delete '/files/:digest' do
if !isHex(params[:digest])
    puts 'test2@@@@@@@@@@@@@@@@@@@@@'
    status 422
  else
    status 200
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
