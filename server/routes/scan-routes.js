const Router = require('express')

const ScanController = require("../controllers/scan-controller")

const getScanRouter = (args) => {
    const router = new Router()
    const scanController = new ScanController(args)

    router.post("/", scanController.handleNNResponse.bind(scanController))

    return router
}

module.exports = getScanRouter
