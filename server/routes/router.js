const Router = require('express')

const userRouter = require('./user-routes')
const addressRouter = require('./address-routes')
const warehouseRouter = require('./warehouse-routes')
const customerRouter = require('./customer-routes')
const getScanRouter = require('./scan-routes')

const getRouter = (args) => {
    const router = new Router()

    router.use("/user", userRouter)
    router.use("/address", addressRouter)
    router.use("/warehouse", warehouseRouter)
    router.use("/customer", customerRouter)
    router.use("/service/scan", getScanRouter(args))

    return router
}

module.exports = getRouter
