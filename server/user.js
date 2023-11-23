const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
var db = require('./db.js');
const cryptoKey = "rafli sayang kripto";

router.route('/register').post((req, res) => {
    var email = req.body.email;
    var name = req.body.name;
    var password = req.body.password;
    const token = jwt.sign({ email: email }, cryptoKey);
    var public_key = req.body.public_key;
    var role = email == 'admin@gmail.com' ? 'admin' : 'user';
    var sqlQuery = "INSERT INTO user VALUES (?,?,?,?,?,?)";

    db.query(sqlQuery, [email, name, password, token, public_key, role], function (error, data, fields) {
        if (error) {
            res.send(JSON.stringify({ success: false, message: error }));
        } else {
            res.send(JSON.stringify({ success: true, message: 'register' }));
        }
    });

});

router.route('/login').post((req, res) => {

    var email = req.body.email;
    var password = req.body.password;

    var sql = "SELECT * FROM user WHERE email=? AND password=?";

    if (email != "" && password != "") {
        db.query(sql, [email, password], function (err, data, fields) {
            if (err) {
                res.send(JSON.stringify({ success: false, message: err }));
            } else {
                if (data.length > 0) {
                    const token = jwt.sign({ email: email }, cryptoKey);
                    res.send(JSON.stringify({ success: true, user: data, token: token }));
                } else {
                    res.send(JSON.stringify({ success: false, message: 'Empty Data' }));
                }
            }
        });
    } else {
        res.send(JSON.stringify({ success: false, message: 'Email and password required!' }));
    }

});

router.route('/getAdminPublicKey').post((req, res) => {

    var email = 'admin@gmail.com'

    var sql = "SELECT public_key FROM user WHERE email=?";

    db.query(sql, email, function (err, data, fields) {
        if (err) {
            res.send(JSON.stringify({ success: false, message: err }));
        } else {
            if (data.length > 0) {
                res.send(JSON.stringify({ success: true, user: data}));
            } else {
                res.send(JSON.stringify({ success: false, message: 'Empty Data' }));
            }
        }
    });
}
);


module.exports = router;