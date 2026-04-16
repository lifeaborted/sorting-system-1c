const Router = require('express')
const router = new Router()

const userRouter = require('./user-routes')
const addressRouter = require('./address-routes')
const warehouseRouter = require('./warehouse-routes')
const customerRouter = require('./customer-routes')

router.use("/user", userRouter)
router.use("/address", addressRouter)
router.use("/warehouse", warehouseRouter)
router.use("/customer", customerRouter)

module.exports = router