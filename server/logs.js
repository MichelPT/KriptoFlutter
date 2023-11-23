const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
var db = require('./db.js');

router.route('/upload').post((req, res) => {
    var logTitle = req.body.title
    var logDescription = req.body.description
    var imageHexString = req.body.image
    var email = req.body.email
    var sqlQuery = "INSERT INTO logs (title, description, image, user_email) VALUES (?,?,?,?)";

    db.query(sqlQuery, [logTitle, logDescription, imageHexString, email], function (error, data, fields) {
        if (error) {
            res.send(JSON.stringify({ success: false, message: error }));
        } else {
            res.send(JSON.stringify({ success: true, message: 'log is uploaded' }));
        }
    });
});

router.route('/all').post((req, res)=> {
    var email = req.body.email;
    var sqlQuery = "SELECT * FROM logs WHERE user_email = ?";
    db.query(sqlQuery, email, function (error, data, fields) {
        if (error) {
            res.send(JSON.stringify({ success: false, message: error }));
        } else {
            res.send(JSON.stringify({ success: true, logs: data }));
        }
    });
})


router.route('/allasAdmin').get((req, res)=> {
    var sqlQuery = "SELECT * FROM logs";
    db.query(sqlQuery, function (error, data, fields) {
        if (error) {
            res.send(JSON.stringify({ success: false, message: error }));
        } else {
            res.send(JSON.stringify({ success: true, logs: data }));
        }
    });
})
module.exports = router;