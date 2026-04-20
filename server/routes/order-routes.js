const Router = require('express')
const router = new Router()

const orderController = require("../controllers/order-controller")
const checkRoleMiddleware = require('../middleware/check-role-middleware')

router.post('/new', checkRoleMiddleware("manager"), orderController.addNew)
router.delete('/remove/:id', checkRoleMiddleware("manager"), orderController.remove)
router.get('/:id', checkRoleMiddleware("manager"), orderController.findOne)
router.get('/', checkRoleMiddleware("manager"), orderController.findAll)
router.post('/item', checkRoleMiddleware("manager"), orderController.addItem)
router.delete('/item/:id', checkRoleMiddleware("manager"), orderController.deleteItem)

module.exports = router
