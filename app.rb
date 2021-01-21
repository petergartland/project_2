require 'sinatra'
require 'digest'
require 'json'

get '/' do
  redirect "/files/"
  #status 333
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
  	    bod = {"uploaded" => bod}
	  	body bod.to_json
	  	status 201
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


def resp(bod, stat)
	body bod
	status stat
end
