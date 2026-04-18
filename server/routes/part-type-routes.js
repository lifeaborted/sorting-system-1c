const Router = require('express')
const router = new Router()

const partTypeController = require("../controllers/part-type-controller")
const checkRoleMiddleware = require('../middleware/check-role-middleware')

router.post('/new', checkRoleMiddleware("manager"), partTypeController.addNew)
router.delete('/remove', checkRoleMiddleware("manager"), partTypeController.remove)
router.get('/:id', checkRoleMiddleware("manager"), partTypeController.findOne)
router.get('/', checkRoleMiddleware("manager"), partTypeController.findAll)

module.exports = router