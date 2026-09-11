const express = require('express')
const cors = require('cors')
const mysql = require('mysql2')
require('dotenv').config()
const { validatePokemonPayload } = require('./validation')
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

function normalizeType2(type2) {
    const value = String(type2 ?? '').trim()
    return value && value.toLowerCase() !== 'none' ? value : 'None'
}

function findDuplicatePokemon({ name, num, id }, callback) {
    const query = id
        ? 'SELECT `name`, `num` FROM `Pokemon` WHERE (LOWER(`name`) = LOWER(?) OR `num` = ?) AND `id` <> ? LIMIT 1'
        : 'SELECT `name`, `num` FROM `Pokemon` WHERE LOWER(`name`) = LOWER(?) OR `num` = ? LIMIT 1'
    const params = id ? [name, num, id] : [name, num]

    pool.query(query, params, (err, rows) => {
        if (err) return callback(err)
        callback(null, rows[0] || null)
    })
}

function duplicateError(row, name, num) {
    if (row.name && row.name.toLowerCase() === name.toLowerCase()) {
        return 'Pokemon name already exists'
    }
    if (row.num === num) return 'Pokemon number already exists'
    return 'Pokemon name or number already exists'
}

app.post('/pokemon', (req, res) => {
    const validationError = validatePokemonPayload(req.body)
    if (validationError) return res.status(400).json({ error: validationError })

    const name = String(req.body.name).trim()
    const num = String(req.body.num).trim()
    findDuplicatePokemon({ name, num }, (duplicateErr, duplicate) => {
        if (duplicateErr) {
            console.error('Error checking duplicate Pokemon:', duplicateErr)
            return res.status(500).json({ error: 'Error checking existing Pokemon' })
        }
        if (duplicate) {
            return res.status(409).json({ error: duplicateError(duplicate, name, num) })
        }

        pool.query(
            'INSERT INTO `Pokemon` (`name`, `total`, `hp`, `atk`, `def`, `spatk`, `spdef`, `spd`, `avatar`, `type1`, `type2`, `num`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [name, req.body.total, req.body.hp, req.body.atk, req.body.def, req.body.spatk, req.body.spdef, req.body.spd, req.body.avatar, req.body.type1, normalizeType2(req.body.type2), num],
            function (err, results) {
                if (err) {
                    console.error('Error in POST /pokemon:', err)
                    return res.status(500).json({ error: 'Error adding pokemon' })
                }
                res.status(200).send(results)
            }
        )
    })
})

app.put('/pokemon', (req, res) => {
    if (!req.body.id) return res.status(400).json({ error: 'Pokemon id is required' })
    const validationError = validatePokemonPayload(req.body)
    if (validationError) return res.status(400).json({ error: validationError })

    const name = String(req.body.name).trim()
    const num = String(req.body.num).trim()
    findDuplicatePokemon({ name, num, id: req.body.id }, (duplicateErr, duplicate) => {
        if (duplicateErr) {
            console.error('Error checking duplicate Pokemon:', duplicateErr)
            return res.status(500).json({ error: 'Error checking existing Pokemon' })
        }
        if (duplicate) {
            return res.status(409).json({ error: duplicateError(duplicate, name, num) })
        }

        pool.query(
            'UPDATE `pokemon` SET `name`=?, `total`=?, `hp`=?, `atk`=?, `def`=?, `spatk`=?, `spdef`=?, `spd`=?, `avatar`=?, `type1`=?, `type2`=?, `num`=? WHERE id =?',
            [name, req.body.total, req.body.hp, req.body.atk, req.body.def, req.body.spatk, req.body.spdef, req.body.spd, req.body.avatar, req.body.type1, normalizeType2(req.body.type2), num, req.body.id],
            function (err, results) {
                if (err) {
                    console.error('Error in PUT /pokemon:', err)
                    return res.status(500).json({ error: 'Error updating pokemon' })
                }
                res.send(results)
            }
        )
    })
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
