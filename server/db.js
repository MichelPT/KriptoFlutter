const express=require('express');
var mysql=require('mysql2');

var connection=mysql.createConnection
({
    host : 'localhost',
    user : 'root',
    password : '',
    port : '3306',        
    database : 'wms'  
});


connection.connect(function(err){
    if(err) throw err;
    console.log('db connected');
});


module.exports = connection;