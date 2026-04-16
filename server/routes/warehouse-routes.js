const Router = require('express')
const router = new Router()

const warehouseController = require("../controllers/warehouse-controller")
const checkRoleMiddleware = require('../middleware/check-role-middleware')

router.post('/new', checkRoleMiddleware("manager"), warehouseController.addNew)
router.delete('/remove', checkRoleMiddleware("manager"), warehouseController.remove)
router.get('/:id', checkRoleMiddleware("manager"), warehouseController.findOne)
router.get('/', checkRoleMiddleware("manager"), warehouseController.findAll)

module.exports = router
