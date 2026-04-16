const Router = require('express')
const router = new Router()

const userRouter = require('./user-routes')
const addressRouter = require('./address-routes')
const warehouseRouter = require('./warehouse-routes')
const customerRouter = require('./customer-routes')
const scanRouter = require('./scan-routes')

router.use("/user", userRouter)
router.use("/address", addressRouter)
router.use("/warehouse", warehouseRouter)
router.use("/customer", customerRouter)
router.use("/service/scan", scanRouter)

module.exports = router
