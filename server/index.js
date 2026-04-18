require('dotenv').config()

const express = require('express')
const cors = require('cors')
const http = require('http')
const fileUpload = require('express-fileupload')

const database = require('./database/database')
const router = require('./routes/router')
const socket = require('./controllers/service-controller')

// Server settings
const PORT = process.env.HTTP_PORT || 5000

const app = express()
app.use(cors())
app.use(express.json())
app.use(fileUpload({}))
app.use('/api', router)

const server = http.createServer(app)
server.on("upgrade", socket.authenticate.bind(socket))

const start = async () => {
    try
    {
        // Init database
        await database.authenticate()
        await database.sync()
        server.listen(PORT, () => {
            console.log(`REST API server started on port ${PORT}`)
            console.log(`WebSocket server started on port ${PORT}`)
        })
    }
    catch (e)
    {
        console.log(e)
    }
}

start()
