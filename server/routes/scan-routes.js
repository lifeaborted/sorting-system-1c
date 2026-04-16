const express = require('express')
const Router = require('express')
const router = new Router()

const scanController = require("../controllers/scan-controller")

router.post("/", scanController.handleNNResponse)

module.exports = router
