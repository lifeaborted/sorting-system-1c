const Router = require('express')
const router = new Router()

const userRouter = require('./user-routes')

router.use("/user", userRouter)

module.exports = router