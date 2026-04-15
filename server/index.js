require('dotenv').config()
const express = require('express')
const cors = require('cors')

const database = require('./database/database')
const router = require('./routes/router')

const PORT = process.env.PORT || 5000

const app = express()
app.use(cors())
app.use(express.json())
app.use('/api', router)

const start = async () => {
    try
    {
        await database.authenticate()
        await database.sync()
        app.listen(PORT, () => console.log(`Server started on port ${PORT}`))
    }
    catch (e)
    {
        console.log(e)
    }
}


start()
