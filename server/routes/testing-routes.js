const Router = require('express')
const router = new Router()

const testingController = require("../controllers/testing-controller")

router.get("/init", testingController.init)

module.exports = router
