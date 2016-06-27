var express = require('express');
var app = express();

app.get('*', function(request, response){
	response.sendFile(__dirname + request.url);
});

app.listen(8080, function(){
	console.log('Running on port 8080');
});