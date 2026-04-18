const Router = require('express')
const router = new Router()

const scanController = require("../controllers/scan-controller")
const checkApiKeyMiddleware = require("../middleware/check-api-key-middleware")

router.post("/scan", checkApiKeyMiddleware, scanController.scanCode.bind(scanController))

module.exports = router
