const express = require('express')
const cors = require('cors')
const mysql = require('mysql2')
require('dotenv').config()
const app = express()

app.use(cors())
app.use(express.json())

const pool = mysql.createPool(process.env.DATABASE_URL)

pool.on('connection', (connection) => {
    connection.on('error', (err) => {
        console.error('MySQL connection error:', err.code)
    })
})

app.get('/', (req, res) => {
    res.send('Hello world!!')
})

app.get('/pokemon', (req, res) => {
    pool.query(
        'SELECT * FROM pokemon',
        function (err, results, fields) {
            res.send(results)
        }
    )
})

app.get('/pokemon/:id', (req, res) => {
    const id = req.params.id;
    pool.query(
        'SELECT * FROM pokemon WHERE id = ?', [id],
        function (err, results, fields) {
            res.send(results)
        }
    )
})

app.post('/pokemon', (req, res) => {
    pool.query(
        'INSERT INTO `Pokemon` (`name`, `total`, `hp`, `atk`, `def`, `spatk`, `spdef`, `spd`, `avatar`, `type1`, `type2`, `num`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [req.body.name, req.body.total, req.body.hp, req.body.atk, req.body.def, req.body.spatk, req.body.spdef, req.body.spd, req.body.avatar, req.body.type1, req.body.type2, req.body.num],
        function (err, results, fields) {
            if (err) {
                console.error('Error in POST /pokemon:', err);
                res.status(500).send('Error adding pokemon');
            } else {
                res.status(200).send(results);
            }
        }
    )
})

app.put('/pokemon', (req, res) => {
    pool.query(
        'UPDATE `pokemon` SET `name`=?, `total`=?, `hp`=?, `atk`=?, `def`=?, `spatk`=?, `spdef`=?, `spd`=?, `avatar`=?, `type1`=?, `type2`=?, `num`=? WHERE id =?',
        [req.body.name, req.body.total, req.body.hp, req.body.atk, req.body.def, req.body.spatk, req.body.spdef, req.body.spd, req.body.avatar, req.body.type1, req.body.type2, req.body.num, req.body.id],
         function (err, results, fields) {
            res.send(results)
        }
    )
})

app.delete('/pokemon', (req, res) => {
    pool.query(
        'DELETE FROM `pokemon` WHERE id =?',
        [req.body.id],
         function (err, results, fields) {
            res.send(results)
        }
    )
})

app.listen(process.env.PORT || 3000, () => {
    console.log('http://localhost:3000/')
})

// export the app for vercel serverless functions
module.exports = app;
