require('dotenv').config()

const express = require('express')
const {WebSocketServer} = require('ws')
const cors = require('cors')

const database = require('./database/database')
const getRouter = require('./routes/router')

// Server settings
const HTTP_PORT = process.env.HTTP_PORT || 5000
const WS_PORT = process.env.WS_PORT || 5050

const wss = new WebSocketServer({port: WS_PORT})

const app = express()
app.use(cors())
app.use(express.json())
app.use('/api', getRouter({wss: wss}))

const start = async () => {
    try
    {
        // Init database
        await database.authenticate()
        await database.sync()

        // Start HTTP server
        app.listen(HTTP_PORT, () => {
            console.log(`HTTP server started on port ${HTTP_PORT}`)
        })
    }
    catch (e)
    {
        console.log(e)
    }
}

start()
