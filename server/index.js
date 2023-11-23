const express=require('express');
const app=express();
var bodyParser=require('body-parser');
app.use(bodyParser.json({ limit: '50mb' })); 
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

app.use(express.json());
app.use(bodyParser.urlencoded({extended:true}));

const userRouter=require('./user');
app.use('/user',userRouter);

const logRouter=require('./logs');
app.use('/logs',logRouter);

app.listen(3000,()=>console.log('your server is running on port 3000'));
