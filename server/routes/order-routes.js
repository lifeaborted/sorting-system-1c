const Router = require('express')
const router = new Router()

const orderController = require("../controllers/order-controller")
const checkRoleMiddleware = require('../middleware/check-role-middleware')

router.post('/new', checkRoleMiddleware("manager"), orderController.addNew)
// router.delete('/remove', checkRoleMiddleware("manager"), orderController.remove)
// router.get('/:id', checkRoleMiddleware("manager"), orderController.findOne)
// router.get('/', checkRoleMiddleware("manager"), orderController.findAll)

module.exports = router